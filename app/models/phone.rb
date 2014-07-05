class Phone < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :original
  validates_uniqueness_of :number

  before_validation :normalize

  private 

  def convert_city_phones(num)
    case num
      # Megaphone
      when /^\+7863226/
        num.gsub /863/, '928'
      when /^\+7863229/
        num.gsub /863/, '928'
      when /^\+7863296/
        num.gsub /863/, '928'
      when /^\+7863270/
        num.gsub /863/, '928'
      when /^\+7863279/
        num.gsub /863/, '928'
      #MTS
      when /^\+7863275/
        num.gsub /863275/, '918555'
      when /^\+7863294/
        num.gsub /863294/, '918554'
      when /^\+7863298/
        num.gsub /863298/, '918558'
      #Beeline
      when /^\+7863256/
        num.gsub /863256/, '903406'
      when /^\+7863221/
        num.gsub /863221/, '903401'
      else
        self.number
    end
  end

  def normalize
    self.number = original.gsub(/[\(\)\-_ ]+/, '')
    self.number.gsub!(/^8/, '+7')

    if self.number.length == 6
      self.number = "2#{self.number}"
    end

    if self.number.length == 7
      self.number = "+7863#{self.number}"
    end

    self.number = convert_city_phones(self.number)

  end

end
