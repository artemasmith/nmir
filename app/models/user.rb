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
  before_validation :set_params, :on => :create
  enum :role => [:owner, :agent, :admin]

  def set_params
    o =  [('a'..'z'), ('A'..'Z'), (0..9)].map{|i| i.to_a}.flatten
    self.email = "#{(0..16).map{ o[rand(o.length)] }.join}@gmail.com" if self.email.blank?
    self.password = self.password_confirmation = (0..16).map{ o[rand(o.length)] }.join if self.password.blank?
  end



end
