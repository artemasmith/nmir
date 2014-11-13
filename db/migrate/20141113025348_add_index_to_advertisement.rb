class AddIndexToAdvertisement < ActiveRecord::Migration
  def change
    add_index :advertisements, :adv_type
  end
end
