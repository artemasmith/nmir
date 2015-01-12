class CreateDeletedAdvertisement < ActiveRecord::Migration
  def change
    create_table :deleted_advertisements do |t|
      t.integer :advertisement_id
      t.integer :section_id
    end
    add_index :deleted_advertisements, :advertisement_id
  end
end
