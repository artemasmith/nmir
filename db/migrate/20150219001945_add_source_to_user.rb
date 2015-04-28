class AddSourceToUser < ActiveRecord::Migration

  def change
    add_column :users, :source, :integer, not_null: true, default: 0
  end

  def up
    Location.where('title ~* ?', '^сад\s').update_all(location_type: 9)
  end

end
