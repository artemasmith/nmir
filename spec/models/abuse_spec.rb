require 'rails_helper'

RSpec.describe Abuse, :type => :model do
  before do
    @user = FactoryGirl.create(:user)
    @user.update(role: 0)
    @advertisement = FactoryGirl.create(:advertisement, user: @user)
    #@advertisement.update(user_id: @user.id)
    @abuse1 = FactoryGirl.create(:abuse, abuse_type: 0, advertisement_id: @advertisement.id)
    @abuse2 = FactoryGirl.create(:abuse, abuse_type: 1, advertisement_id: @advertisement.id)
  end

  it "should update_user status if agent abuse accepted" do
    @abuse1.update(status: 1)
    @user.reload
    @user.role.should eq('agent')
  end

  it 'should change advertisement status to rejected' do
    @abuse2.update(status: 1)
    @advertisement.reload
    @advertisement.status_type.should eq('rejected')
  end


end