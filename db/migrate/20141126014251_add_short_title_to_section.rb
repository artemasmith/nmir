class AddShortTitleToSection < ActiveRecord::Migration
  def change
    add_column :sections, :short_title, :string
  end
end
