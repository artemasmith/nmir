class AddPositionToLocation < ActiveRecord::Migration
  def down
    remove_column :locations, :position
  end

  def up
    add_column :locations, :position, :integer, not_null: true, default: 0
    Location.where('title ~* ?', '^сад\s').update_all(location_type: 9)
    Location.where('title ~* ?', 'Ростов-на').update_all(position: 1)
  end
end
