class AddDeltaToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :delta, :boolean, :default => true,
               :null => false
    add_column :advertisements, :changed_at, :datetime
  end
end
