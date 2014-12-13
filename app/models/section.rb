# == Schema Information
#
# Table name: sections
#
#  id                   :integer          not null, primary key
#  advertisements_count :integer          default(0)
#  url                  :string(255)
#  description          :text
#  keywords             :text
#  p                    :text
#  title                :string(255)
#  h1                   :string(255)
#  h2                   :string(255)
#  h3                   :string(255)
#  location_id          :integer
#  offer_type           :integer
#  category             :integer
#  property_type        :integer
#  p2                   :text
#  short_title          :string(255)
#

class Section < ActiveRecord::Base
  belongs_to :location

  enum category: AdvEnums::CATEGORIES 
  enum offer_type: AdvEnums::OFFER_TYPES
  enum property_type: AdvEnums::PROPERTY_TYPES


  scope :not_empty, -> { where('advertisements_count > 0') }

  scope :child_for, -> { joins('INNER JOIN "locations" ON "sections"."location_id" = "locations"."id"')}







end
