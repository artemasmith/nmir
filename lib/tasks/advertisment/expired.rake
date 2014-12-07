namespace :advertisement do
  desc "Change status of adv by date"
  task status: :environment do
    slice_count = 3000
    Advertisement.active.find_in_batches(batch_size: slice_count).each do |group|
      group.each do |adv|
        adv.expired! unless adv.yandex_valid?
      end
    end

    Advertisement.expired.where(['updated_at < ?', DateTime.now - 90.days]).find_in_batches(batch_size: slice_count).each do |group|
      group.each do |adv|
        adv.delete
      end
    end

    Section.find_in_batches(batch_size: slice_count).each do |group|
      group.each do |section|
        advertisement = Advertisement.active
        advertisement = advertisement.joins('INNER JOIN "advertisement_locations" ON "advertisements"."id" = "advertisement_locations"."advertisement_id"')
        advertisement = advertisement.where('advertisement_locations.location_id' => section.location_id)
        advertisement = advertisement.where(offer_type: section.offer_type) if section.offer_type.present?
        advertisement = advertisement.where(category: section.category) if section.category.present?
        advertisement = advertisement.where(property_type: section.property_type) if section.property_type.present?
        section.advertisements_count = advertisement.count
        section.save
      end
    end
  end
end