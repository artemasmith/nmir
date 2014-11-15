class RemoveMissingColumnsFromUser < ActiveRecord::Migration
  def change
    %w(avatar_file_name avatar_content_type avatar_file_size avatar_updated_at advertisement_photo_file_name advertisement_photo_content_type advertisement_photo_file_size advertisement_photo_updated_at).each {|c| remove_column :users, c}
  end
end
