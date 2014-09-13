class CreateNotepads < ActiveRecord::Migration
  def change
    create_table :notepads do |t|
      t.references :user, index: { name: 'index_notepads_on_user_id' }
      t.references :advertisement, index: { name: 'index_notepads_on_advertisement_id' }
      t.timestamps
    end
  end
end
