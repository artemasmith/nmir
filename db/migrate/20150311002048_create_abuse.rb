class CreateAbuse < ActiveRecord::Migration
  def change
    create_table :abuses do |t|
      t.integer :advertisement_id
      t.string :comment
      t.integer :user_id
      t.integer :abuse_type
      t.integer :status
      t.string :moderator_comment
      t.timestamps
    end
    add_index :abuses, :advertisement_id
  end
end
