# == Schema Information
#
# Table name: phones
#
#  id       :integer          not null, primary key
#  number   :string(255)
#  original :string(255)
#  user_id  :integer
#

class Phone < ActiveRecord::Base
  belongs_to :user
  has_many :advertisements, through: :user


  validates_presence_of :original
  validates_uniqueness_of :number

  before_validation :normalize

  after_save :update_advs
  def normalize
    self.number = Phone.normalize(original)
  end

  def self.convert_city_phones(phone)
    case phone
      # Megaphone
      when /^\+7863226/
        phone.gsub /863/, '928'
      when /^\+7863229/
        phone.gsub /863/, '928'
      when /^\+7863296/
        phone.gsub /863/, '928'
      when /^\+7863270/
        phone.gsub /863/, '928'
      when /^\+7863279/
        phone.gsub /863/, '928'
      #MTS
      when /^\+7863275/
        phone.gsub /863275/, '918555'
      when /^\+7863294/
        phone.gsub /863294/, '918554'
      when /^\+7863298/
        phone.gsub /863298/, '918558'
      #Beeline
      when /^\+7863256/
        phone.gsub /863256/, '903406'
      when /^\+7863221/
        phone.gsub /863221/, '903401'
      else
        phone
    end
  end

  def self.normalize(phone)
    number = phone.gsub(/[\(\)\-_ ]+/, '')
    number.gsub!(/^8/, '+7')

    number = "2#{number}" if number.length == 6

    if number.length == 7
      number = "+7863#{number}"
    elsif number.length == 10
      number = "+7#{number}"
    end

    convert_city_phones(number)
  end

  def update_advs
    phones = self.user.phones.map{ |p| p.number }.join(', ')
    Advertisement.where(user_id: self.user_id).update_all(phone: phones)
  end

end
