# == Schema Information
#
# Table name: advertisement_locations
#
#  id               :integer          not null, primary key
#  advertisement_id :integer
#  location_id      :integer
#

class AdvertisementLocation < ActiveRecord::Base
  belongs_to :advertisement
  belongs_to :location
end

