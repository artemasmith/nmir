class SetDefaultAbuseStatus < ActiveRecord::Migration
  def change
    change_column :abuses, :status, :integer, default: 0
  end
end
