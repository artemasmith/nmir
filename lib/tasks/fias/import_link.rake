namespace :fias do
  desc "Link locations from fias"

  task link_locations: :environment do
    sql = 'UPDATE locations as t1 SET location_id=(SELECT id FROM locations as t2 WHERE t2.aoguid = t1.parentguid)'
    ActiveRecord::Base.connection.execute(sql)
  end

end