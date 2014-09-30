# == Schema Information
#
# Table name: locations
#
#  id                :integer          not null, primary key
#  title             :string(255)
#  translit          :string(255)
#  location_type     :integer
#  location_id       :integer
#  children_count    :integer          default(0)
#  admin_area_id     :integer
#  non_admin_area_id :integer
#  city_id           :integer


class Location < ActiveRecord::Base
  has_many :sublocations, class_name: 'Location', foreign_key: "location_id"
  has_many :sublocations_for_city, class_name: 'Location', primary_key: "city_id"
  belongs_to :parent_location, class_name: 'Location', foreign_key: "location_id"


  before_save :transliterate_title
  before_create :adress_initialize


  # neighbors
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

    #if parent.to_i == 0
    #  id = Location.find_by_title(parent).id
    #end
    Location.where('location_id = ?', id)
  end


  def children_locations(type = :all)
    case self.location_type.to_sym
      when :region, :district, :street, :address, :landmark
        self.sublocations
      when :city
        case type
          when :all
            self.sublocations
          when :admin_area
            self.sublocations.where(location_type: 3)
          when :non_admin_area
            self.sublocations.where(location_type: 4)
          when :street
            self.sublocations.where(location_type: 5)
          else
            raise "Invalide type"
        end
      when :admin_area
        self.sublocations_for_city.where(admin_area_id: self.id)
      when :non_admin_area
        self.sublocations_for_city.where(location_type: 5)
      else
        raise "Type error"
    end
  end

  def self.group_location(elem, array, res)
    res << elem if !res.include?(elem)
    children=[]
    array.each do |el|
      children << el if el.parent_location == elem
    end
    children.each do |child|
      group_location(child, array, res)
    end
  end

  private

  def adress_initialize
    if self.address? || self.admin_area? || self.non_admin_area?
      node = self.parent_location
      while true
        if node.city?
          self.city_id = node.id
          return
        else
          node = node.parent_location
        end
      end
    end
  end

  def transliterate_title
    self.translit = Russian::translit(self.title).downcase
  end
end
