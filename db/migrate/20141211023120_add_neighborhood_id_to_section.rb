class AddNeighborhoodIdToSection < ActiveRecord::Migration
  def change
    add_column :sections, :neighborhood_id, :integer, default: nil
    add_index :sections, :neighborhood_id
  end

end
