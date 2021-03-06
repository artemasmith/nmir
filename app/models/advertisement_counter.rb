# == Schema Information
#
# Table name: advertisement_counters
#
#  id               :integer          not null, primary key
#  advertisement_id :integer
#  counter_type     :integer
#  count            :integer          default(0)
#  created_at       :datetime
#  updated_at       :datetime
#

class AdvertisementCounter < ActiveRecord::Base
  enum counter_type: [:today, :all_days]

  def self.get_and_increase_count_for_adv(advertisement_id)
    counters = AdvertisementCounter.where(advertisement_id: advertisement_id).to_a
    today_counter = counters.find { |counter| counter.today? } || AdvertisementCounter.create({advertisement_id: advertisement_id, counter_type: :today})
    all_days_counter = counters.find { |counter| counter.all_days? } || AdvertisementCounter.create({advertisement_id: advertisement_id, counter_type: :all_days})
    if today_counter.updated_at.to_date < DateTime.now.to_date
      today_counter.count = 0
      today_counter.updated_at = DateTime.now
    end
    today_counter.increase!
    all_days_counter.increase!
    return today_counter, all_days_counter
  end

  def increase!
    self.count += 1
    self.save
  end
end
