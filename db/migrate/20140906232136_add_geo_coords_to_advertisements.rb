class AddGeoCoordsToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :latitude, :float
    add_column :advertisements, :longitude, :float
  end
end
