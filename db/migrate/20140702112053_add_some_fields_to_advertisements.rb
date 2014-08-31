class AddSomeFieldsToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisments, :landmark, :string
    add_column :advertisments, :comment, :text
    add_column :advertisments, :private_comment, :text
    add_column :advertisments, :adv_type, :integer, not_null: true

  end
end
