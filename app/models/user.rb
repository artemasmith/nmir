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

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :trackable

  has_many :advertisements

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :phones, dependent: :destroy
  accepts_nested_attributes_for :phones, allow_destroy: true
  accepts_nested_attributes_for :advertisements
  enum :role => AdvEnums::USER_ROLES
  before_validation :set_params, :on => :create
  after_update :change_adv_role, :if => :role_changed?
  validates_presence_of :role


  def set_params
    o =  [('a'..'z'), ('A'..'Z'), (0..9)].map{|i| i.to_a}.flatten
    self.email = "#{(0..16).map{ o[rand(o.length)] }.join}@gmail.com" if self.email.blank?
    self.password = self.password_confirmation = (0..16).map{ o[rand(o.length)] }.join if self.password.blank?
  end

  def change_adv_role
    Advertisement.where(user_id: self.id).update_all({user_role: self.role})
  end

  def self.get_contact cinfo
    if cinfo[:phone].blank?
      return false
    end
    phone = Phone.where('number = ?',Phone.normalize(cinfo[:phone])).first

    if phone.present?
      return phone.user
    else
      return false
    end
  end

end
