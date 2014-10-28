class AddPreviewToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :preview_url, :string
    add_column :advertisements, :preview_alt, :string
  end
end
