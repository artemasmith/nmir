# == Schema Information
#
# Table name: sections
#
#  id                   :integer          not null, primary key
#  advertisements_count :integer          default(0)
#  url                  :string(255)
#  description          :text
#  keywords             :text
#  p                    :text
#  title                :string(255)
#  h1                   :string(255)
#  h2                   :string(255)
#  h3                   :string(255)
#  location_id          :integer
#  offer_type           :integer
#  category             :integer
#  property_type        :integer
#  p2                   :text
#  short_title          :string(255)
#

class Section < ActiveRecord::Base
  belongs_to :location

  enum category: AdvEnums::CATEGORIES 
  enum offer_type: AdvEnums::OFFER_TYPES
  enum property_type: AdvEnums::PROPERTY_TYPES


  scope :not_empty, -> { where('advertisements_count > 0') }
  scope :great_than_10, -> { where('advertisements_count > 10') }

  scope :child_for, -> { joins('INNER JOIN "locations" ON "sections"."location_id" = "locations"."id"')}

  def self.root
    Section.where(offer_type: nil, category: nil, location_id: nil, property_type: nil).first
  end

  def correct!
    return if self.location_id.blank?
    location = Location.find(location_id)
    locations = Location.parent_locations(location).reverse

    locations_chain_array = locations
    loc_chain_url = SectionGenerator.chain_url(locations_chain_array.map(&:title))
    case
      when self.offer_type == nil && self.property_type == nil && self.category == nil
      then
        begin
          url_ = "/#{loc_chain_url}"
          if self.url != url_
            print "was: #{self.url}"
            print "became: #{url_}"
            self.url = url_
            self.save!
          end
        end
      when self.property_type.present? && self.offer_type.present?
      then
        begin
          url_ = "/#{loc_chain_url}/#{SectionGenerator.chain_url([self.offer_type, self.property_type])}"
          if self.url != url_
            print "was: #{self.url}"
            print "became: #{url_}"
            self.url = url_
            self.save!
          end
        end
      when self.category.present? && self.offer_type.present?
      then
        begin
          url_ = "/#{loc_chain_url}/#{SectionGenerator.chain_url([self.offer_type, self.category])}"
          if self.url != url_
            print "was: #{self.url}"
            print "became: #{url_}"
            self.url = url_
            self.save!
          end
        end
      else
        raise 'invalide type'
    end
  end
end
