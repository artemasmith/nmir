namespace :advertisement do
  desc "Change status of adv by date"
  task status: :environment do
    slice_count = 3000
    Advertisement.active.find_in_batches(batch_size: slice_count).each do |group|
      group.each do |adv|
        adv.expired! unless adv.yandex_valid?
        adv.save
      end
    end

    Advertisement.expired.where(['updated_at < ?', DateTime.now - 90.days]).find_in_batches(batch_size: slice_count).each do |group|
      group.each do |adv|
        adv.delete
      end
    end

    Section.find_in_batches(batch_size: slice_count).each do |group|
      group.each do |section|
        section.advertisements_count = Advertisement
            .active
            .where(offer_type: section.offer_type, category: section.category, property_type: section.property_type)
            .joins('INNER JOIN "advertisement_locations" ON "advertisements"."id" = "advertisement_locations"."advertisement_id"')
            .where('advertisement_locations.location_id' => section.location_id).count
        section.save
      end
    end
  end
end