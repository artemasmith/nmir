# == Schema Information
#
# Table name: deleted_advertisements
#
#  id               :integer          not null, primary key
#  advertisement_id :integer
#  section_id       :integer
#

class DeletedAdvertisement < ActiveRecord::Base
  belongs_to :section
end

