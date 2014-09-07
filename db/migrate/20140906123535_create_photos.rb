class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :advertisement_id
      t.string :comment
      t.timestamps
    end
    add_attachment :photos, :advertisement_photo
  end

  def self.down
    drop_table :photos
  end

end
