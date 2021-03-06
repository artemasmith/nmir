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
#  aoguid            :string(255)
#  parentguid        :string(255)
#  admin_area_id     :integer
#  non_admin_area_id :integer
#  city_id           :integer
#  loaded_resource   :boolean          default(FALSE), not null
#  status_type       :integer          default(0)
#

class Location < ActiveRecord::Base
  has_many :sublocations, class_name: 'Location', foreign_key: "location_id"
  has_many :sublocations_for_city, class_name: 'Location', primary_key: "city_id"
  belongs_to :parent_location, class_name: 'Location', foreign_key: "location_id"

  before_save :transliterate_title
  after_find :load_resources





  # neighbors
  # has_and_belongs_to_many :neighbors,
  #                         class_name: 'Location',
  #                         join_table: 'neighborhoods',
  #                         foreign_key: 'location_id',
  #                         association_foreign_key: 'neighbor_id'



  def self.locations_list
    %w(region district city admin_area non_admin_area street address cottage garden complex landmark)
  end




  # remember! add values to the end of array

  LOCATION_TYPES = [:region, #1
                    :district, #3,
                    :city, #4, #6
                    :admin_area, # 5
                    :non_admin_area,
                    :street, #7
                    :address,
                    :landmark,
                    :cottage,
                    :garden,
                    :complex

  ]

  enum location_type: LOCATION_TYPES

  enum status_type: [:unchecked,
                       :checked,
                       :blocked]




  scope :children_of, ->(id) { where(location_id: id) }



  # recursively collect all parent location nodes and return them in array
  def self.parent_locations(l, memo = [])
    memo << l
    if l.parent_location
      Location.parent_locations(l.parent_location, memo)
    else
      return memo
    end
  end

  def has_children?
    self.children_count > 0
  end

  def self.suggest_location parent_id, term, type
    children = where(location_id: parent_id.to_i).where(location_type: LOCATION_TYPES.index(type.to_sym)).where('LOWER(title) like ?', "%#{term.to_s.mb_chars.downcase}%").limit(5)
    children.map{ |l| { label: l.title, value: l.id, has_children: l.has_children? } }
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
      when :region, :street, :address, :landmark, :cottage, :garden, :complex
        self.sublocations
      when :district
        case type
          when :all
            self.sublocations
          when :cottage
            self.sublocations.where(location_type: LOCATION_TYPES.index(:cottage))
          when :garden
            self.sublocations.where(location_type: LOCATION_TYPES.index(:garden))
          when :complex
            self.sublocations.where(location_type: LOCATION_TYPES.index(:complex))
          else
            raise 'Invalid type'
        end
      when :city
        case type
          when :all
            self.sublocations
          when :admin_area
            self.sublocations.where(location_type: LOCATION_TYPES.index(:admin_area))
          when :non_admin_area
            self.sublocations.where(location_type: LOCATION_TYPES.index(:non_admin_area))
          when :street
            self.sublocations.where(location_type: LOCATION_TYPES.index(:street))
          when :cottage
            self.sublocations.where(location_type: LOCATION_TYPES.index(:cottage))
          when :garden
            self.sublocations.where(location_type: LOCATION_TYPES.index(:garden))
          when :complex
            self.sublocations.where(location_type: LOCATION_TYPES.index(:complex))
          when :not_street
            self.sublocations.where(location_type: [LOCATION_TYPES.index(:admin_area), LOCATION_TYPES.index(:non_admin_area)])
          else
            raise 'Invalid type'
        end
      when :admin_area
        self.sublocations_for_city.where(admin_area_id: self.id)
      when :non_admin_area
        self.sublocations_for_city.where(location_type: LOCATION_TYPES.index(:non_admin_area))



      else
        raise 'Type error'
    end
  end

  def loaded_resource!
    self.loaded_resource = true
    self.save
  end

  private
  def load_resources
    return if self.loaded_resource

    self.children_count = children_locations.count

    if self.address? || self.admin_area? || self.non_admin_area?
      node = self.parent_location
      while node.present?
        if node.city?
          self.city_id = node.id
          break
        else
          node = node.parent_location
        end
      end
    end
    self.loaded_resource = true
    self.save
  end

  def transliterate_title
    self.translit = Russian::translit(self.title).downcase
  end

end
