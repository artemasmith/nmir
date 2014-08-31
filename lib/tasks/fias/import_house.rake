namespace :fias do

  def house_path(index)
    index_to_s = index < 10 ? "0#{index}" : "#{index}"
    ENV['path'].blank? ? "lib/fias_db/HOUSE#{index_to_s}.DBF" : File.join(ENV['path'], "HOUSE#{index_to_s}.DBF")
  end

  desc "generate local tables house"
  task generate_local_table_house: :environment do
    (1..99).each do |i|
      next if ENV['region'].present? && ENV['region'].to_i != i
      return if !File.exist?(house_path(i))
      DbfWrapper.new(house_path(i)).make_local_data("HOUSE#{i}")
    end
  end

  desc "Generate houses from fias"
  task generate_house: :environment do
    (1..99).each do |index|
      next if ENV['region'].present? && ENV['region'].to_i != i
      return if !File.exist?(house_path(i))
      eval("class DbfTableHouse#{index} < ActiveRecord::Base; self.table_name = '#{DbfWrapper.new(house_path(index)).table_name}'; end")
      eval("DbfTableHouse#{index}.reset_column_information")
      Location.reset_column_information
      record_count = eval("DbfTableHouse#{index}.count")
      current_record_count = 0
      slice_count = 3000
      summ_count = record_count / slice_count
      index = 0

      eval("DbfTableHouse#{index}").find_in_batches(batch_size: slice_count) do |group|
        time = Time.now
        Location.transaction do
          group.each do |record|
            location = Location.new
            location.title = "#{ record.housenum }#{record.buildnum.to_s.strip != "" ? (" корп. " + record.buildnum) : ""}#{record.strucnum.to_s.strip != "" ? " стр. " + record.strucnum : ""}"
            location.location_type = :address
            location.aoguid = record.houseguid
            location.parentguid = record.aoguid
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
        puts "Generate houses:#{current_record_count}/#{record_count}/Time:#{days}:#{hours}:#{minutes}:#{seconds}"
      end
    end
  end

end