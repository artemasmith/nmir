require 'rails_helper'

RSpec.describe CabinetCounter do


  describe "advs counter calcultaion" do
    before do
      @user = FactoryGirl.create(:user)
      adv1 = FactoryGirl.create(:advertisement, user: @user, status_type: 0)
      adv2 = FactoryGirl.create(:advertisement, user: @user, status_type: 1)
      adv3 = FactoryGirl.create(:advertisement, user: @user, status_type: 2)
      puts "user advs #{@user.advertisements.count}"
    end

    it { CabinetCounter.total_adv_count(@user.id).should eq(3) }
    it { expect(CabinetCounter.active_adv_count(@user.id)).to eq(1) }
    it { expect(CabinetCounter.expired_adv_count(@user.id)).to eq(1) }

  end
end