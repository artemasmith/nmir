class AddStatusTypeToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisments, :status_type, :integer, null: false, default: 0
    remove_column :advertisments, :expire_date
  end
end
