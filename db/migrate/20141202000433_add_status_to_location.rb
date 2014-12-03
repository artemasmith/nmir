class AddStatusToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :status_type, :integer, not_null: true, default: 0
  end
end
