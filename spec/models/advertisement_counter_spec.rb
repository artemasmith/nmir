require 'rails_helper'

RSpec.describe AdvertisementCounter, :type => :model do
  it "should increase and return list of counter" do
    today, all_days = AdvertisementCounter.get_and_increase_count_for_adv(1)
    expect(today.present?).to be_truthy
    expect(all_days.present?).to be_truthy
  end
end
