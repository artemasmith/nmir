# == Schema Information
#
# Table name: sections
#
#  id                  :integer          not null, primary key
#  advertisements_count :integer          default(0)
#  url                 :string(255)
#  description         :text
#  keywords            :text
#  p                   :text
#  title               :string(255)
#  h1                  :string(255)
#  h2                  :string(255)
#  h3                  :string(255)
#  location_id         :integer
#  offer_type          :integer
#  category            :integer
#  property_type       :integer
#

class Section < ActiveRecord::Base
  belongs_to :location

  enum category: AdvEnums::CATEGORIES 
  enum offer_type: AdvEnums::OFFER_TYPES
  enum property_type: AdvEnums::PROPERTY_TYPES

  #delegate :title, :translit, to: :location, prefix: true

  #before_save :generate_title
  #before_save :generate_url

  scope :not_empty, -> { where('advertisements_count > 0') }

  private

  def generate_title

    if(offer_type && category)
      
      self.title = "#{Section.enum_title(offer_type)} #{Section.enum_title(category)} в #{location.title}"
    
    elsif(offer_type && property_type)

      self.title = "#{Section.enum_title(offer_type)} #{Section.enum_title(property_type)} недвижимость в #{location.title}"

    elsif(offer_type.blank? && property_type.blank? && category.blank?)

      self.title = "Недвижимость в #{location.title}"
    end
    
  end

  def generate_url
    self.url = "#{location.translit}/#{Section.enum_url(offer_type)}/#{Section.enum_url(category)}"
  end

end
