class AddLocationsTitleToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :locations_title, :string
    add_column :advertisements, :landmark, :string
  end
end
