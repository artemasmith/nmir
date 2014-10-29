class AddPToSection < ActiveRecord::Migration
  def change
    add_column :sections, :p2, :text
  end
end
