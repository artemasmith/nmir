class AddSourceToUser < ActiveRecord::Migration
  def change
    add_column :users, :source, :integer, not_null: true, default: 0
  end
end
