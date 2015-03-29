require 'rails_helper'

RSpec.describe CabinetCounter do
  describe 'abuses counters calculation' do
    before do
      user = FactoryGirl.create(:user)
      @abuse_user = FactoryGirl.create(:user, email: 'abuse@ab.ru')
      user.update(role: 0)
      advertisement = FactoryGirl.create(:advertisement, user: user)
      #@advertisement.update(user_id: @user.id)
      abuse1 = FactoryGirl.create(:abuse, abuse_type: 0, advertisement_id: advertisement.id, user: @abuse_user)
      abuse2 = FactoryGirl.create(:abuse, abuse_type: 1, advertisement_id: advertisement.id, user: @abuse_user)
      abuse3 = FactoryGirl.create(:abuse, abuse_type: 2, status: 1, advertisement_id: advertisement.id, user: @abuse_user)
      abuse4 = FactoryGirl.create(:abuse, abuse_type: 3, status: 2, advertisement_id: advertisement.id, user: @abuse_user)
    end

    it 'should show 3 waiting abuses' do
      CabinetCounter.waiting_abuse_count(@abuse_user.id).should eq(2)
    end

    it 'when 1 accepted and 1 declined abuses should show 2 considered' do
      CabinetCounter.considered_abuse_count(@abuse_user.id).should eq(2)
    end

    it { expect(CabinetCounter.total_abuse_count(@abuse_user.id)).to eq(4)}
  end
end