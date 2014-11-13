class AddIndexToLocation < ActiveRecord::Migration
  def change
    add_index :locations, :title
  end
end
