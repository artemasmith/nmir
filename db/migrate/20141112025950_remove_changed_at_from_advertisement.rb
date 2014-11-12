class RemoveChangedAtFromAdvertisement < ActiveRecord::Migration
  def change
    remove_column :advertisements, :changed_at
  end
end
