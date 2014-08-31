class ChangeNameOfAdv < ActiveRecord::Migration
  def change
    rename_table :advertisments, :advertisements
    rename_column(:sections, :advertisments_count, :advertisements_count)
  end
end
