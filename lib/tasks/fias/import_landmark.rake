namespace :fias do
  desc "generate local tables landmark"

  def landmark_path
    ENV['path'].blank? ? "lib/fias_db/LANDMARK.DBF" : File.join(ENV['path'].blank, "LANDMARK.DBF")
  end

  task generate_local_table_landmark: :environment do
    DbfWrapper.new(landmark_path).make_local_data("LANDMARK")
  end


  desc "Generate landmark from fias"
  task generate_landmark: :environment do

    eval("class DbfLandmark < ActiveRecord::Base; self.table_name = '#{DbfWrapper.new(landmark_path).table_name}'; end")
    Location.reset_column_information
    DbfLandmark.reset_column_information
    record_count = DbfLandmark.count
    current_record_count = 0
    slice_count = 3000
    summ_count = record_count / slice_count
    index = 0
    DbfLandmark.reset_column_information
    DbfLandmark.where(actstatus: 1).find_in_batches(batch_size: slice_count) do |group|
      time = Time.now
      Location.transaction do
        group.each do |record|
          location = Location.new
          location.title = record.location
          location.location_type = :landmark
          location.aoguid = record.landguid
          location.parentguid = record.aogid
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
      puts "Generate landmark:#{current_record_count}/#{record_count}/Time:#{days}:#{hours}:#{minutes}:#{seconds}"
    end

  end



end