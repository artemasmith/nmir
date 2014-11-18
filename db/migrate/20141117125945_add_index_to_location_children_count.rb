class AddIndexToLocationChildrenCount < ActiveRecord::Migration
  def change
    add_index :locations, :children_count
    #add_index :locations, :title
  end
end
