class AddLoadedResourceToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :loaded_resource, :boolean, :default => false,
               :null => false
  end
end
