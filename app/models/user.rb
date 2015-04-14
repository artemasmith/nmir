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
#  source                 :integer          default(0)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :trackable



  has_many :advertisements, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :phones, dependent: :destroy
  accepts_nested_attributes_for :phones, allow_destroy: true
  accepts_nested_attributes_for :advertisements



  enum :role => AdvEnums::USER_ROLES

  USER_SOURCES = [:unknown, :donrio, :adresat]
  enum :source => User::USER_SOURCES
  before_validation :set_params, :on => :create
  #before_save :deny_admin_thread
  after_update :change_adv_role, :if => :role_changed?
  after_update :change_advs, if: :name_changed?
  validate :role_changed

  def role_changed
    if self.role_changed?
      errors.add :role, 'Нет прав для смены' if self.role_was.to_sym != :admin && self.role.to_sym == :admin
    end
  end

  def set_params
    o =  [('a'..'z'), ('A'..'Z'), (0..9)].map{|i| i.to_a}.flatten
    self.email = "#{(0..16).map{ o[rand(o.length)] }.join}@.gmail.com" if self.email.blank?
    self.password = self.password_confirmation = (0..16).map{ o[rand(o.length)] }.join if self.password.blank?
  end

  def change_adv_role
    Advertisement.where(user_id: self.id).update_all({user_role: AdvEnums::USER_ROLES.index(self.role.to_sym)})
  end

  def self.get_contact cinfo
    if cinfo[:phone].blank? || cinfo[:name].blank?
      return false
    end
    phone = Phone.where('number = ?', Phone.normalize(cinfo[:phone])).first

    if phone.present? && phone.user.present?
      return phone.user
    elsif phone.present?
      phone.destroy
    end
    if cinfo[:phone].match /[[:alpha:]]/
      return false
    else
      user = User.create!(email: "#{cinfo[:phone]}@.gmail.com",
                         name: "#{cinfo[:name]}",
                         password: "#{Time.now.to_i}",
                         role: cinfo[:agent].present? ? cinfo[:agent] : 0,
                         from_admin: true,
                         source: cinfo[:source])
      user.phones.create!(original: cinfo[:phone])
      return user
    end
  end


  def change_advs
    self.advertisements.update_all(name: self.name)
  end

end
