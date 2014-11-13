# == Schema Information
#
# Table name: advertisements
#
#  id                       :integer          not null, primary key
#  offer_type               :integer          not null
#  property_type            :integer          not null
#  category                 :integer          not null
#  agent_category           :integer
#  currency                 :integer
#  distance                 :integer
#  time_on_transport        :integer
#  time_on_foot             :integer
#  agency_id                :integer
#  floor_from               :integer
#  floor_to                 :integer
#  floor_cnt_from           :integer
#  floor_cnt_to             :integer
#  payed_adv                :boolean          default(FALSE)
#  manually_added           :boolean
#  not_for_agents           :boolean
#  mortgage                 :boolean          default(FALSE)
#  name                     :string(255)
#  sales_agent              :string(255)
#  phone                    :string(255)
#  organization             :string(255)
#  outdoors_space_from      :decimal(15, 2)
#  outdoors_space_to        :decimal(15, 2)
#  price_from               :integer
#  price_to                 :integer
#  unit_price_from          :decimal(15, 2)
#  unit_price_to            :decimal(15, 2)
#  outdoors_unit_price_from :integer
#  outdoors_unit_price_to   :integer
#  space_from               :decimal(15, 2)
#  space_to                 :decimal(15, 2)
#  keywords                 :text
#  created_at               :datetime
#  updated_at               :datetime
#  landmark                 :string(255)
#  comment                  :text
#  private_comment          :text
#  adv_type                 :integer
#  region_id                :integer
#  district_id              :integer
#  city_id                  :integer
#  admin_area_id            :integer
#  non_admin_area_id        :integer
#  street_id                :integer
#  address_id               :integer
#  landmark_id              :integer
#  room_from                :integer
#  room_to                  :integer
#  status_type              :integer          default(0), not null
#  user_id                  :integer
#  latitude                 :float
#  longitude                :float
#

class Advertisement < ActiveRecord::Base

  belongs_to :user
  has_many   :photos, :dependent => :destroy
  has_one   :advertisement_counter, :dependent => :destroy
  accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => :check_photos
  has_and_belongs_to_many :locations, join_table: 'advertisement_locations'


  accepts_nested_attributes_for :user

  include AdvGenerator

  # validators
  include AdvValidation
  validate :category_conformity
  validate :propery_type_conformity

  # Enums
  include AdvEnums
  #rails_admin
  include AdvRailsAdmin

  after_create :generate_sections
  
  def grouped_allowed_attributes
    return  @grouped_allowed_attributes if defined?(@grouped_allowed_attributes)
    @grouped_allowed_attributes = []
    allowed_attributes.each do |attr|
      if match = attr.match(/(.+)(_to|_from)$/i)
        prefix = match[1]
        suffix = match[2]
        next if suffix == '_to'
        if allowed_attributes.find{|e| e == "#{prefix}_to"}
          @grouped_allowed_attributes << %W(#{prefix}_from #{prefix}_to)
        else
          @grouped_allowed_attributes << %W(#{prefix}_from)
        end
      else
        @grouped_allowed_attributes << [attr]
      end
    end
    return @grouped_allowed_attributes
  end

  def allowed_attributes
    return @allowed_attributes if defined?(@allowed_attributes)
    @allowed_attributes = AdvConformity::ATTR_VISIBILITY[adv_type][category] rescue []
  end

  # define methods like :price, from pirce_from attr
  attribute_names.grep(/_from/).each do |from_method|
    method_name = from_method.match(/(\w+)_from/)[1].to_sym
    define_method(method_name) { return self[from_method] }
  end




  def yandex_valid?
    time_now = Time.now
    case
      when sale? && flat? then (created_at > time_now - 90.days) || (updated_at > time_now - 45.days)
      when rent? && flat? then (created_at > time_now - 7.days) || (updated_at > time_now - 14.days)
      when sale? && room? then (created_at > time_now - 120.days) || (updated_at > time_now - 45.days)
      when rent? && room? then (created_at > time_now - 25.days) || (updated_at. > time_now - 24.days)
      when rent? && house? then (created_at > time_now - 30.days) || (updated_at > time_now - 30.days)
      else
        (self.created_at > time_now - 60.days) || (self.updated_at > time_now - 30.days)
    end
  end

  def location_ids=(location_ids)
    return if (location_ids || []).empty?
    l = Location.where(id: location_ids).all
    valid = true
    l.each do |location|
      valid &&= location.location_id.blank? || l.find{|item| item.id == location.location_id}.present?
    end
    if valid
      locations.delete_all
      l.each do |location|
        locations << location
      end
    end
  end



  private

  def locations_chain_array_from(location)
    ls = self.locations.all
    result = []
    while location.present?
      result << location
      location_id = location.location_id
      location = ls.find{|l| l.id == location_id}
    end
    result.reverse
  end

  def generate_sections
    self.locations.each do |loc|
      locations_chain_array = locations_chain_array_from(loc)
      locations_chain_url = SectionGenerator.chain_url(locations_chain_array.map(&:title))
      locations_chain_title = locations_chain_array.map(&:title).join(' ')
      SectionGenerator.by_offer_category(offer_type, category, loc, locations_chain_url, locations_chain_title)
      SectionGenerator.by_property_offer(property_type, offer_type, loc, locations_chain_url, locations_chain_title)
      SectionGenerator.by_location(loc, locations_chain_url, locations_chain_title)
    end
    SectionGenerator.empty
  end

  def category_conformity
    unless AdvConformity::TYPE_CONFORMITY[self.offer_type].try(:include?, category)
      errors.add :base, "Неверный тип категории"
    end
  end

  def propery_type_conformity
    unless AdvConformity::TYPE_CONFORMITY[self.property_type].try(:include?, offer_type)
      errors.add :base, 'Неверный тип объекта'
    end
  end

  def check_photos(photo_attr)
    if photo = Find.find(photo_attr['id'])
      self.photos << photo
      return true
    end
    return false
  end

end

