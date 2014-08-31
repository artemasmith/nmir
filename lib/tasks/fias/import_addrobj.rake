namespace :fias do
  addrobj_path = ENV['path'].blank? ? 'lib/fias_db/ADDROBJ.DBF' : File.join(ENV['path'], "ADDROBJ.DBF")

  desc "generate local table addrobj"
  task generate_local_table_addrobj: :environment do
    DbfWrapper.new(addrobj_path).make_local_data("ADDROBJ")
  end

  desc "Generate locations from fias"
  task generate_addrobj: :environment do
    eval("class DbfTable < ActiveRecord::Base; self.table_name = '#{DbfWrapper.new(addrobj_path).table_name}'; end")
    Location.reset_column_information
    DbfTable.reset_column_information

    current_record_count = 0
    slice_count = 3000
    summ_count = record_count / slice_count
    index = 0
    DbfTable.reset_column_information
    table = DbfTable
    table = table.where(regioncode: ENV['region']) if ENV['region'].present?
    table = table.where(actstatus: 1)
    record_count = table.count
    table.where(actstatus: 1).find_in_batches(batch_size: slice_count) do |group|
      time = Time.now
      Location.transaction do
        group.each do |record|
          location_type = case record.aolevel.to_i
                            when 1 then :region
                            when 3 then :district
                            when 4 then :city
                            when 5 then :admin_area
                            when 6 then :city
                            when 7 then :street
                            when 90 then :city
                            when 91 then :city
                            else next
                          end
          location = Location.new
          location.title = "#{record.shortname} #{record.offname}"
          location.location_type = location_type
          location.aoguid = record.aoguid
          location.parentguid = record.parentguid
          location.save
          current_record_count += 1
        end
      end
      time_for_slice = Time.now - time
      index += 1
      seconds = (summ_count - index) * time_for_slice.to_i
      days = seconds / 86400
      hours = seconds / 3600
      minutes = (seconds - (hours * 3600)) / 60
      seconds = (seconds - (hours * 3600) - (minutes * 60))
      puts "#{current_record_count}/#{record_count}/Time remain for generate:#{days}:#{hours}:#{minutes}:#{seconds}"
    end

  end
end