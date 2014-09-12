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

require 'rails_helper'

RSpec.describe AdvertisementCounter, :type => :model do
  it "should increase and return list of counter" do
    today, all_days = AdvertisementCounter.get_and_increase_count_for_adv(1)
    expect(today.present?).to be_truthy
    expect(all_days.present?).to be_truthy
  end
end
