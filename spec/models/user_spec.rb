# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  blocked                :boolean          default(FALSE)
#  from_admin             :boolean          default(FALSE)
#  role                   :integer
#

require 'rails_helper'

RSpec.describe User, :type => :model do

  describe 'has some fields and' do
    subject(:user) { new_user }
    
    it { expect(user).to respond_to(:name) }
    it { expect(user).to respond_to(:blocked) }
    it { expect(user).to respond_to(:role) }
    it { expect(user).to respond_to(:from_admin) }
  end

  describe 'permissions check' do
    it 'owner should not create_from_admin' do
      user = FactoryGirl.create(:user, role: :owner)
      ab = Ability.new(user)
      ab.can?(:create_from_admin, Advertisement).should eq false
    end

    it 'agent cant create_from_Admin' do
      user = FactoryGirl.create(:user, role: :agent)
      ab = Ability.new(user)
      ab.can?(:create_from_admin, Advertisement).should eq false
    end

    it 'owner can create adv' do
      user = FactoryGirl.create(:user, role: :owner)
      ab = Ability.new(user)
      ab.can?(:create, Advertisement).should eq true
    end
  end
end

def new_user
  User.new({
    name: 'asdsdsd',
    email: 'asd@asd.ru',
    role: :owner,
    password: '11111111',
    password_confirmation: '11111111'
  })
end
