class AddChildrenCountToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :children_count, :integer, default: 0
  end
end
