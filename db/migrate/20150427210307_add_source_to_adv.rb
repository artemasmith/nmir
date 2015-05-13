class AddSourceToAdv < ActiveRecord::Migration
  def down
    remove_column :advertisements, :source
    add_column :users, :from_admin, :boolean, default: false
  end

  def up
    add_column :advertisements, :source, :integer, not_null: true, default: 0
    User.where(from_admin: true).where(source: User::USER_SOURCES.index(:unknown)).update_all({source: User::USER_SOURCES.index(:manual)})
    Advertisement.update_all('source = (SELECT "users"."source" FROM "users" WHERE "users"."id" = "advertisements"."user_id")')
    remove_column :users, :from_admin
  end
end
