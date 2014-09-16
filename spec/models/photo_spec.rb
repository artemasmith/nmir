# == Schema Information
#
# Table name: photos
#
#  id                               :integer          not null, primary key
#  advertisement_id                 :integer
#  comment                          :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  advertisement_photo_file_name    :string(255)
#  advertisement_photo_content_type :string(255)
#  advertisement_photo_file_size    :integer
#  advertisement_photo_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe Photo, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
