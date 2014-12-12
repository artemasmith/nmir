# == Schema Information
#
# Table name: neighborhoods
#
#  id          :integer          not null, primary key
#  location_id :integer
#  neighbor_id :integer
#

class Neighborhood < ActiveRecord::Base
  belongs_to :parent_location, class_name: 'Location', foreign_key: "location_id"
  belongs_to :child_location, class_name: 'Location', foreign_key: "neighbor_id"
end
