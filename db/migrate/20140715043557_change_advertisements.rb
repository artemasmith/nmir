class ChangeAdvertisements < ActiveRecord::Migration
  def up
    change_column :advertisments, :outdoors_space_unit, :string
    change_column :advertisments, :price_to, :integer
    change_column :advertisments, :price_from, :integer
    change_column :advertisments, :outdoors_unit_price_to, :integer
    change_column :advertisments, :outdoors_unit_price_from, :integer

    remove_column :advertisments, :period
    remove_column :advertisments, :rooms

    add_column :advertisments, :room_from, :integer
    add_column :advertisments, :room_to, :integer
  end

  def down
    change_column :advertisments, :outdoors_space_unit, :decimal, precision: 15, scale: 2
    change_column :advertisments, :price_to, :decimal, precision: 15, scale: 2
    change_column :advertisments, :price_from, :decimal, precision: 15, scale: 2
    change_column :advertisments, :outdoors_unit_price_to, :decimal, precision: 15, scale: 2
    change_column :advertisments, :outdoors_unit_price_from, :decimal, precision: 15, scale: 2

    add_column :advertisments, :period, :integer
    add_column :advertisments, :rooms, :integer

    remove_column :advertisments, :room_from
    remove_column :advertisments, :room_to
  end
end
