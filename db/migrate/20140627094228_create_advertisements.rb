class CreateAdvertisements < ActiveRecord::Migration
  def change
    create_table :advertisments do |t|

      # Enums
      t.integer :offer_type, null: false
      t.integer :property_type, null: false
      t.integer :category, null: false
      t.integer :agent_category    	
      t.integer :currency
      t.integer :period

      # Int attrs
      t.integer :distance
      t.integer :time_on_transport
      t.integer :time_on_foot
      t.integer :agency_id
      t.integer :floor_from
      t.integer :floor_to
      t.integer :floor_cnt_from
      t.integer :floor_cnt_to
      t.integer :rooms

      t.datetime :expire_date

      t.boolean :payed_adv, default: false
      t.boolean :manually_added, delfault: true
      t.boolean :not_for_agents
      t.boolean :mortgage, default: false

      t.string :name
      t.string :sales_agent
      t.string :phone
      t.string :organization
      t.string :space_unit

      t.decimal :outdoors_space_from, precision: 4, scale: 2
      t.decimal :outdoors_space_to, precision: 4, scale: 2
      t.decimal :outdoors_space_unit, precision: 4, scale: 2
      t.decimal :price_from, precision: 10, scale: 2
      t.decimal :price_to, precision: 10, scale: 2
      t.decimal :unit_price_from, precision: 4, scale: 2
      t.decimal :unit_price_to, precision: 4, scale: 2
      t.decimal :outdoors_unit_price_from, precision: 4, scale: 2
      t.decimal :outdoors_unit_price_to, precision: 4, scale: 2
      t.decimal :space_from, precision: 4, scale: 2
      t.decimal :space_to, precision: 4, scale: 2

      t.text :keywords

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

      t.timestamps
    end
  end
end
