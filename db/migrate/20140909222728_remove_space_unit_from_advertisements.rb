class RemoveSpaceUnitFromAdvertisements < ActiveRecord::Migration
  def change
    remove_column :advertisements, :space_unit
    remove_column :advertisements, :outdoors_space_unit
  end
end
