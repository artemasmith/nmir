# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  translit      :string(255)
#  location_type :integer
#  location_id   :integer
#

class Location < ActiveRecord::Base
  has_many :sublocations, class_name: 'Location', foreign_key: "location_id"

  belongs_to :parent_location, class_name: 'Location', foreign_key: "location_id"

  before_save :transliterate_title

  # neighbors
  #has_many :neighborhoods, dependent: :destroy
  #has_many :neighbors, through: :neighborhoods
  has_and_belongs_to_many :neighbors, 
                          class_name: 'Location', 
                          join_table: 'neighborhoods',
                          foreign_key: 'location_id',
                          association_foreign_key: 'neighbor_id'

  # remember! add values to the end of array
  enum location_type: [:region, #1
                       :district, #3,
                       :city, #4, #6
                       :admin_area, # 5
                       :non_admin_area,
                       :street, #7
                       :address,
                       :landmark]

  scope :children_of, ->(id) { where(location_id: id) }


  # recursively collect all parent location nodes and return them in array
  def self.parent_locations(l, memo = [])
    if l.parent_location
      memo << l.parent_location
      Location.parent_locations(l.parent_location, memo)
    else
      return memo
    end
  end

  #parent - title or id of parent location
  # to_i of string always returns zero, and there is no zero ids
  def self.get_children(parent)
    #Maybe we need to index locations?
    #cond = parent.to_i == 0 ? { parent_title: parent } : { parent_id: parent }
    #Location.search(conditions: cond)
    id = parent.to_i
    if parent.to_i == 0
      id = Location.find_by_title(parent).id
    end
    Location.where('location_id = ?', id)
  end

  def parent?
    location_type == 'region'
  end

  private

  def transliterate_title
    self.translit = Russian::translit(self.title).downcase
  end
end
