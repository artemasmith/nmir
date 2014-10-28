class AddMetaToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :description, :text
    add_column :advertisements, :p, :text
    add_column :advertisements, :title, :string
    add_column :advertisements, :h1, :string
    add_column :advertisements, :h2, :string
    add_column :advertisements, :h3, :string
    add_column :advertisements, :url, :string
    add_column :advertisements, :anchor, :string
  end
end
