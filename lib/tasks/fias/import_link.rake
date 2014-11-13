namespace :fias do
  desc "Link locations from fias"

  task link_locations: :environment do



    record_count = Location.count
    current_record_count = 0
    slice_count = 300
    summ_count = record_count / slice_count
    index = 0
    Location.find_in_batches(batch_size: slice_count) do |group|
      time = Time.now
      group.each do |record|
        parent_location = Location.where(aoguid: record.parentguid).first
        if parent_location.present?
          record.location_id = parent_location.id

          if record.address? || record.admin_area? || record.non_admin_area?
            node = record.parent_location
            while true
              break if node.nil?
              if node.city?
                record.city_id = node.id
                break
              else
                node = node.parent_location
              end
            end
          end

          record.save
        end
        current_record_count += 1
      end
      time_for_slice = Time.now - time
      index += 1
      seconds = (summ_count - index) * time_for_slice.to_i
      days = seconds / 86400
      hours = seconds / 3600
      minutes = (seconds - (hours * 3600)) / 60
      seconds = (seconds - (hours * 3600) - (minutes * 60))
      puts "Link locations:#{current_record_count}/#{record_count}/Time:#{days}:#{hours}:#{minutes}:#{seconds}"
    end
  end

end