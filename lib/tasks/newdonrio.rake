#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :import do
  desc "Импорт информации из донрио"

  task(:donrio, [:file] => :environment) do |_, args|



    def find_address_locations_in_db parent, path, result
      return result, false if path.blank?

      sub_location = parent.children_locations.where('title ilike ?', "%#{path.first}%").first
      return nil, false if sub_location.blank?
      result << sub_location

      if sub_location.street? && path.second.present? && path.second.to_i > 0
        sub_sub_location = sub_location.children_locations.where(title: path.second.to_i.to_s).first ||
                           create_address(parent: sub_location, title: path.second.to_i.to_s)
        result << sub_sub_location
        return nil, true
      end

      return sub_location, false
    end

    def find_locations_in_db parent_name, original_district, original_address, result = []

      district_name = Matcher.rename_district(original_district)
      original_address = original_address.to_s.gsub(original_district.to_s, '')
      address_name = Matcher.rename_district(original_address)

      if district_name.is_a?(String) || district_name.is_a?(NilClass)
        superparent = Location.where(title: parent_name).first

        correct_district_name = Matcher.escape district_name

        return result, [original_district, original_address].delete_if{|e| e.blank?}.join(', ') if correct_district_name.blank?
        if superparent.city?
          district = superparent.children_locations(:admin_area).where('title ilike ?', "%#{correct_district_name}%").first ||
                     superparent.children_locations(:non_admin_area).where('title ilike ?', "%#{correct_district_name}%").first ||
                     superparent.children_locations(:street).where('title ilike ?', "%#{correct_district_name}%").first
        else
          district = superparent.children_locations.where('title ilike ?', "%#{correct_district_name}%").first
        end

        return result, [original_district, original_address].delete_if{|e| e.blank?}.join(', ') if district.blank?

        result << superparent
        result << district
      else
        result = district_name
        district = result.last
      end

      if address_name.is_a?(String) || address_name.is_a?(NilClass)
        correct_address_name = Matcher.escape address_name

        return result, original_address if correct_address_name.blank?

        address_name_list = correct_address_name.split('/').delete_if{ |e| e.blank? }
        path_list = address_name_list.first.split(',').map{ |e| e.to_s.strip }.delete_if{ |e| e.blank? } if address_name_list.first.present?
        addition_path_list = address_name_list.second.split(',').map{ |e| e.to_s.strip }.delete_if{ |e| e.blank? } if address_name_list.second.present?

        address, parsed = find_address_locations_in_db district, path_list, result
        if address.blank?
          return result, parsed ? nil : original_address
        end

        address, parsed = find_address_locations_in_db address, addition_path_list, result
        if address.blank?
          return result, parsed ? nil : original_address.split('/').delete_if{ |e| e.blank? }.second
        end
      else
        result << address_name
      end

      return result, nil
    end

    def get_location loc_params
      district = loc_params[:dist]
      address = loc_params[:addr]

      ro = Location.where(title: 'обл Ростовская').first
      result, unparsed = find_locations_in_db('г Ростов-на-Дону', district, address, [ro])
      result, unparsed =  find_locations_in_db('обл Ростовская', district, address) if result == [ro]

      if unparsed.present?
        result, unparsed = find_locations_in_db('г Ростов-на-Дону', district, address, [ro])
        result, unparsed =  find_locations_in_db('обл Ростовская', district, address) if result == [ro]
      end
      return (result.presence || [ro]), unparsed, unparsed.present?
    end


    def create_address attr
      parent = attr[:parent]
      address = parent.sublocations.create(title: attr[:title], location_type: :address)
      parent.loaded_resource!
      address
    end


    #TASK STARTS
    args.file ||= '/home/tea/RubymineProjects/nmir/public/import/first_test_donrio.xls'
    log = Logger.new STDOUT
    log.debug "\nARGS= #{args} \n"
    adv = {}
    titles = {}
    workbook = Spreadsheet.open(args.file).worksheets
    workbook.each do |worksheet|
      titles.clear

      worksheet.each do |row|
        if titles.empty?
          row.each_with_index do |column, index|
            titles[column] = index if column.present?
          end
          next
        end

        next if row.count == 0 || row.compact.count == 0

        #here we are looking for client info
        name, phone = DonrioParser.parse_name_and_phone row, titles

        #print "\nname=#{name}\n"

        adv = Advertisement.new
        contact = User.get_contact(phone: phone, name: name.presence || '(имя не указано)', source: User::USER_SOURCES.index(:donrio))

        if contact
          adv.user = contact
        else
          log.warn("could not recognize name=#{name.presence || '(имя не указано)'} & phone=#{phone} or find it in db for #{row[titles['Тел контанк']]}")
          next
        end

        adv.offer_type = DonrioParser.parse_offer_type row
        adv.category = DonrioParser.parse_category row, titles

        floor_from = DonrioParser.parse_floor_from row, titles
        adv.floor_from = floor_from if floor_from.present? && floor_from > 0
        floor_cnt_from = DonrioParser.parse_floor_cnt_from row, titles
        adv.floor_cnt_from = floor_cnt_from if floor_cnt_from.present? && floor_cnt_from > 0


        room_from = DonrioParser.parse_room row, titles
        adv.room_from = room_from if room_from.present? && room_from > 0

        space_from = DonrioParser.parse_space_from row, titles
        adv.space_from = space_from if space_from.present? && space_from > 0


        outdoors_space_from = DonrioParser.parse_outdoors_space_from row, titles
        adv.outdoors_space_from = outdoors_space_from if outdoors_space_from.present? && outdoors_space_from > 0

        adv.price_from = DonrioParser.parse_price row



        location = { dist: row[titles['Район']], addr: row[titles['Адрес']]}
        locations, unparsed, success = get_location(location)

        unless success
          log.error("could not recognize address=#{row[titles['Район']]} & #{row[titles['Адрес']]}")
        end


        adv.comment = DonrioParser.parse_comment row, titles

        adv.landmark = DonrioParser.parse_landmark unparsed

        adv_params = { locations: locations, offer_type: adv.offer_type, category: adv.category, property_type: adv.property_type,
                       user_id: adv.user_id, price: adv.price_from }

        cadv = Advertisement.check_existence adv_params
        adv.locations = locations

        adv.get_remote_coords unless cadv

        unless cadv
          log.warn "\nCould not save advertisement #{adv.errors.full_messages} row: #{ worksheet.rows.index(row) + 1 }\n" unless adv.save
        else
          log.debug "\nWe found same advertisement #{cadv.map(&:id)}\n"
        end
      end
    end

  end
end