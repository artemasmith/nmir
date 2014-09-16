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

class Photo < ActiveRecord::Base
  belongs_to :advertisement
  has_attached_file :advertisement_photo, :styles => { :medium => "800x600>", :thumb => "200x150>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :advertisement_photo, :content_type => /\Aimage\/.*\Z/

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
        'name' => read_attribute(file),
        'url' => file.url,
        'size' => file.size,
        'delete_url' => photo_path(id: id),
        'delete_type' => 'DELETE'
    }
  end
end
