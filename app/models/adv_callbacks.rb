module AdvCallbacks

  extend ActiveSupport::Concern

  included do

    after_create :generate_sections
    after_update :generate_sections
    before_destroy :delete_advertisement

    def delete_advertisement
      CabinetCounter.drop_adv_count(self.user_id)
      return if section.blank?
      deleted_advertisement = DeletedAdvertisement.new
      deleted_advertisement.advertisement_id = self.id
      deleted_advertisement.section_id = section.id
      deleted_advertisement.save
    end

    def generate_sections
      CabinetCounter.drop_adv_count(self.user_id)
      self.locations.each do |loc|
        locations_chain_array = locations_chain_array_from(loc)
        locations_chain_url = SectionGenerator.chain_url(locations_chain_array.map(&:title))
        locations_chain_title = locations_chain_array.map(&:title).join(' ')
        short_loc_title = locations_chain_array.last.try(:title)
        SectionGenerator.by_offer_category(offer_type, category, loc, locations_chain_url, locations_chain_title, short_loc_title)
        SectionGenerator.by_property_offer(property_type, offer_type, loc, locations_chain_url, locations_chain_title, short_loc_title)
        SectionGenerator.by_location(loc, locations_chain_url, locations_chain_title, short_loc_title)
      end
      SectionGenerator.empty
    end

    def section
      return @section if defined? @section
      location_id = Location.
          joins('INNER JOIN "advertisement_locations" ON "locations"."id" = "advertisement_locations"."location_id"').
          where('advertisement_locations.advertisement_id' => self.id).all.to_a.
          sort_by{|location| Location.locations_list.index(location.location_type.to_s)}.last.try(:location_id)
      @section = Section.where(category: Section.categories[self.category]).where(offer_type: Section.offer_types[self.offer_type]).where(location_id: location_id).first || Section.root
    end

  end


end
