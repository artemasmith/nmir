class CreateAdvertisementCounters < ActiveRecord::Migration
  def change
    create_table :advertisement_counters do |t|
      t.integer :advertisement_id
      t.integer :counter_type
      t.integer :count, default: 0
      t.timestamps
    end
    add_index :advertisement_counters, :advertisement_id
  end
end
