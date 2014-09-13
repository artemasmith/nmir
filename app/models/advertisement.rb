# == Schema Information
#
# Table name: advertisements
#
#  id                       :integer          not null, primary key
#  offer_type               :integer          not null
#  property_type            :integer          not null
#  category                 :integer          not null
#  agent_category           :integer
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
#

class Advertisement < ActiveRecord::Base

  belongs_to :region,   class_name: 'Location', foreign_key: 'region_id'
  belongs_to :district, class_name: 'Location', foreign_key: 'district_id'
  belongs_to :city,     class_name: 'Location', foreign_key: 'city_id'
  belongs_to :admin_area,   class_name: 'Location', foreign_key: 'admin_area_id'
  belongs_to :non_admin_area, class_name: 'Location', foreign_key: 'non_admin_area_id'
  belongs_to :street, class_name: 'Location', foreign_key: 'street_id'
  belongs_to :address, class_name: 'Location', foreign_key: 'address_id'
  belongs_to :landmark, class_name: 'Location', foreign_key: 'landmark_id'
  belongs_to :user
  has_many   :photos, :dependent => :destroy
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # validators
  include AdvValidation
  validate :category_conformity
  validate :propery_type_conformity

  # Enums
  include AdvEnums
  #rails_admin
  include AdvRailsAdmin

  before_create :set_locations
  before_validation :check_attributes
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



  def locations
    HashWithIndifferentAccess.new({
      region: region,
      district: district,
      city: city,
      admin_area: admin_area,
      non_admin_area: non_admin_area,
      street: street,
      address: address,
      landmark: landmark
    }).delete_if {|_, v| v.blank? }
  end

  def locations_array
    [region, district, city, admin_area, non_admin_area, street, address, landmark].delete_if do |l|
      l.blank?
    end
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

  def title
    'объявление'
  end

  private

  def check_attributes
    self.name ||= comment[0..15] #это имя человека который размещает объявление
    self.sales_agent ||= user.name || 'no agent'
    self.phone ||= user.phones.first.number || '123' #это номер человека который размещает объявление
  end

  # set all location nodes from one, that submited
  def set_locations
    self.locations.each do |loc_title, loc|
      break if loc_title == :region

      location_nodes = Location.parent_locations(loc)

      location_nodes.each do |node|
        self[ "#{node.location_type}_id" ] = node.id
      end
    end
  end

  def generate_sections
    locations_chain_url = SectionGenerator.chain_url(locations_array.map(&:title))

    self.locations.each do |loc_title, loc|
      # find or create by offer_type + category + each location node, setted in this advertisement
      SectionGenerator.by_offer_category(offer_type, category, loc, locations_chain_url)

      # find or create by property_type + offer_type + each location node, setted in this advertisement
      SectionGenerator.by_property_offer(property_type, offer_type, loc, locations_chain_url)

      # find or create by location node
      SectionGenerator.by_location(loc, locations_chain_url)

    end
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




end

