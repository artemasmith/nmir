class AddIndexToSection < ActiveRecord::Migration
  def change
    add_index :sections, :url
    add_index :sections, :location_id
    add_index :sections, [:offer_type, :category, :location_id, :property_type], name: 'index_sections_on_ot_c_li_pt'
  end
end
