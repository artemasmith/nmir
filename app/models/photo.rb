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
  has_attached_file :advertisement_photo, :styles => { :medium => "1024x720", :thumb => "168x104" }, :default_url => "/images/:style/missing.png", :url => "/system/:class/entity/:id_partition/:style/:filename"
  validates_attachment_content_type :advertisement_photo, :content_type => %w(image/jpeg image/png image/pjpeg image/x-png)

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
        'thumbnail_url' => advertisement_photo.url(:thumb),
        'name' => advertisement_photo_file_name,
        'url' => advertisement_photo.url,
        'size' => advertisement_photo.size,
        'delete_url' => photo_path(id: id),
        'delete_type' => 'DELETE',
        'id' => id
    }
  end
end
