class CreateAdvertisementLocation < ActiveRecord::Migration
  def change
    create_table :advertisement_locations do |t|
      t.references :advertisement, index: { name: 'index_advertisement_location_on_advertisement_id' }
      t.references :location, index: { name: 'index_advertisement_location_on_location_id' }
    end
    ["landmark",
    "region_id",
    "district_id",
    "city_id",
    "admin_area_id",
    "non_admin_area_id",
    "street_id",
    "address_id",
    "landmark_id"].each do |m|
      remove_column :advertisements, m.to_sym
    end
  end

end
