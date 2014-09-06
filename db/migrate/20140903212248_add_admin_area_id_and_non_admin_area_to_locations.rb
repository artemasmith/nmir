class AddAdminAreaIdAndNonAdminAreaToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :admin_area_id, :integer
    add_column :locations, :non_admin_area_id, :integer
    add_column :locations, :city_id, :integer
    add_index :locations, :admin_area_id
    add_index :locations, :non_admin_area_id
    add_index :locations, :city_id
  end
end
