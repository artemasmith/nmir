# == Schema Information
#
# Table name: advertisments
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
#  expire_date              :datetime
#  payed_adv                :boolean          default(FALSE)
#  manually_added           :boolean
#  not_for_agents           :boolean
#  mortgage                 :boolean          default(FALSE)
#  name                     :string(255)
#  sales_agent              :string(255)
#  phone                    :string(255)
#  organization             :string(255)
#  space_unit               :string(255)
#  outdoors_space_from      :decimal(15, 2)
#  outdoors_space_to        :decimal(15, 2)
#  outdoors_space_unit      :string(255)
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
#

class Advertisment < ActiveRecord::Base

  belongs_to :region,   class_name: 'Location', foreign_key: 'region_id'
  belongs_to :district, class_name: 'Location', foreign_key: 'district_id'
  belongs_to :city,     class_name: 'Location', foreign_key: 'city_id'
  belongs_to :admin_area,   class_name: 'Location', foreign_key: 'admin_area_id'
  belongs_to :non_admin_area, class_name: 'Location', foreign_key: 'non_admin_area_id'
  belongs_to :street, class_name: 'Location', foreign_key: 'street_id'
  belongs_to :address, class_name: 'Location', foreign_key: 'address_id'
  belongs_to :landmark, class_name: 'Location', foreign_key: 'landmark_id'

  # validators
  include AdvValidation
  validate :category_conformity
  validate :propery_type_conformity

  # Enums
  include AdvEnums

  before_create :set_locations
  after_create :generate_sections
  
  def allowed_attributes
    AdvConformity::ATTR_VISIBILITY[adv_type][category] rescue []
  end

  # define methods like :price, from pirce_from attr
  attribute_names.grep(/_from/).each do |from_method|
    method_name = from_method.match(/(\w+)_from/)[1].to_sym

    define_method(method_name) { return self[from_method] }
  end

  def locations
    HashWithIndifferentAccess.new({
      non_admin_area: non_admin_area, admin_area: admin_area, region: region, city: city,
      district: district, street: street, address: address, landmark: landmark
    }).delete_if {|k, v| v.blank? }
  end

  def locations_array
    [region, district, city, admin_area, non_admin_area, street, address, landmark].delete_if do |l|
      l.blank?
    end
  end

  private

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
      # find or create by offer_type + category + each location node, setted in this advertisment
      SectionGenerator.by_offer_category(offer_type, category, loc, locations_chain_url)

      # find or create by property_type + offer_type + each location node, setted in this advertisment
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
      errors.add :base, "Неверный тип ???"
    end
  end

end

