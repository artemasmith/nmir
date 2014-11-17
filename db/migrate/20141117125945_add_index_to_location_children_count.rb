class AddIndexToLocationChildrenCount < ActiveRecord::Migration
  def change
    add_index :locations, :children_count
  end
end
