class AddUserRoleToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :user_role, :integer
  end
end
