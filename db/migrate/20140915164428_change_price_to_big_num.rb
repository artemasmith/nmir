class ChangePriceToBigNum < ActiveRecord::Migration
  def change
    change_column :advertisements, :price_from, :bigint
    change_column :advertisements, :price_to, :bigint
  end
end
