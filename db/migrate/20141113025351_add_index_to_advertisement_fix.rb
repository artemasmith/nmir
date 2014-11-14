class AddIndexToAdvertisementFix < ActiveRecord::Migration
  def change
    add_index :advertisements, [:offer_type, :category, :property_type, :status_type], name: 'index_advertisements_on_ot_c_li_pt_st'
    add_index :advertisements, :status_type
    remove_index :advertisements, :adv_type
  end
end
