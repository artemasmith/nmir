class AddLocationFieldsToAdvertisements < ActiveRecord::Migration
  def up
    # remove placeholders
    remove_columns(:advertisments,
      :location_name,
      :location_id,
      :country_name,
      :country_id,
      :region_name,
      :region_id,
      :district_name,
      :district_id,
      :locality_name,
      :locality_id,
      :sub_locality_name,
      :sub_locality_id,
      :non_admin_sub_locality,
      :address_id,
      :address_name,
      :direction_id,
      :direction_name,
      :metro_id,
      :metro_name
    )

    change_table :advertisments do |t|
      t.integer :region_id
      t.integer :district_id
      t.integer :city_id
      t.integer :admin_area_id
      t.integer :non_admin_area_id
      t.integer :street_id
      t.integer :address_id
      t.integer :landmark_id
    end

  end
  
  def down

    remove_columns(:advertisments,
       :region_id,
       :district_id,
       :city_id,
       :admin_area_id,
       :non_admin_area_id,
       :street_id,
       :address_id,
       :landmark_id
    )

    change_table :advertisments do |t|
      t.string :location_name
      t.integer :location_id
      t.string :country_name
      t.integer :country_id
      t.string :region_name
      t.integer :region_id
      t.string :district_name
      t.integer :district_id
      t.string :locality_name
      t.integer :locality_id
      t.string :sub_locality_name
      t.integer :sub_locality_id
      t.string :non_admin_sub_locality
      t.integer :address_id
      t.string :address_name
      t.integer :direction_id
      t.string :direction_name
      t.integer :metro_id
      t.string :metro_name
    end
  end
end
