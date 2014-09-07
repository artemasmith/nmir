class Photo < ActiveRecord::Base
  belongs_to :advertisement
  has_attached_file :advertisement_photo, :styles => { :medium => "800x600>", :thumb => "200x150>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :advertisement_photo, :content_type => /\Aimage\/.*\Z/
end
