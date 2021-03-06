namespace :advertisement do
  desc "Change status of adv by date"
  task status: :environment do
    slice_count = 3000
    Advertisement.where(source: AdvEnums::ADV_SOURCES.index(:unknown)).active.find_in_batches(batch_size: slice_count).each do |group|
      group.each do |adv|
        adv.expired! unless adv.yandex_valid?
      end
    end

    Advertisement.where(source: AdvEnums::ADV_SOURCES.index(:unknown)).expired.where(['updated_at < ?', DateTime.now - 90.days]).find_in_batches(batch_size: slice_count).each do |group|
      group.each do |adv|
        adv.destroy
      end
    end

    Section.find_in_batches(batch_size: slice_count).each do |group|
      group.each do |section|
        advertisement = Advertisement.active
        if section.location_id.present?
          advertisement = advertisement.joins('LEFT OUTER JOIN "advertisement_locations" ON "advertisements"."id" = "advertisement_locations"."advertisement_id"')
          advertisement = advertisement.where('advertisement_locations.location_id' => section.location_id)
        end
        advertisement = advertisement.where(offer_type: Advertisement.offer_types[section.offer_type]) if section.offer_type.present?
        if section.property_type.present?
          if section.residental?
            advertisement = advertisement.where(category: AdvEnums::RESIDENTAL_CATEGORIES)
          elsif section.commerce?
            advertisement = advertisement.where(category: AdvEnums::COMMERCE_CATEGORIES)
          end
        else
          advertisement = advertisement.where(category: Advertisement.categories[section.category]) if section.category.present?
        end
        section.advertisements_count = advertisement.count
        section.save
      end
    end
  end
end