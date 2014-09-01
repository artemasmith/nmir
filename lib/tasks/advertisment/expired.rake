namespace :advertisement do
  desc "Change status of adv by date"
  task status: :environment do
    slice_count = 3000
    Advertisement.find_in_batches(batch_size: slice_count).each do |group|
      group.each do |adv|
        yandex_valid = adv.yandex_valid?
        adv.expired! and next if !yandex_valid && !adv.expired?
        adv.active! and next if yandex_valid && !adv.active?
      end
    end
  end
end