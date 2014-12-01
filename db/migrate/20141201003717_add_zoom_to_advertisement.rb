class AddZoomToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :zoom, :integer, default: 12, null: false
  end
end
