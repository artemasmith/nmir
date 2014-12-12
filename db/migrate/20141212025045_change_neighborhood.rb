class ChangeNeighborhood < ActiveRecord::Migration
  def change
    remove_index :sections, :neighborhood_id
    remove_column :sections, :neighborhood_id, :integer, default: nil
#    remove_column :neighborhoods, :location_id

#    add_column :neighborhoods, :location_id, :integer
    add_index :neighborhoods, :location_id
    add_index :neighborhoods, :neighbor_id

  end
end
