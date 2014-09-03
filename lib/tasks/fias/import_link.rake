namespace :fias do
  desc "Link locations from fias"

  task generate_indexes: environment do
    ActiveRecord::Migration.add_index :locations, :aoguid, using: :btree unless ActiveRecord::Migration.index_exists?(:locations, :aoguid)
    ActiveRecord::Migration.add_index :locations, :parentguid, using: :btree unless ActiveRecord::Migration.index_exists?(:locations, :parentguid)
  end

  task link_locations: :environment do

    sql = 'UPDATE locations as t1 SET location_id=(SELECT id FROM locations as t2 WHERE t2.aoguid = t1.parentguid)'
    ActiveRecord::Base.connection.execute(sql)
  end

  desc "Calc child count for locations from fias"
  task calc_child_count: :environment do
    sql = 'UPDATE locations as t1 SET children_count=(SELECT COUNT(id) FROM locations as t2 WHERE t2.location_id = t1.id)'
    ActiveRecord::Base.connection.execute(sql)
  end

end