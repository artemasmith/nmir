#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :import do
  desc "Импорт информации из донрио"

  task(:donrio, [:file] => :environment) do |t, args|

    def find_locations_in_db locations
      superparent = Location.where('title = ?', locations[:parent]).first
      district = Matcher.rename_district(locations[:district])
      parent = nil
      parent_locations = Location.where('title ilike ?', "%#{district}%").where('location_type < 5')
      if parent_locations.count >= 1
        if parent_locations.where('title ilike ?', district).count == 1
          parent = parent_locations.where('title ilike ?', district).first
        else
          #same named locations example Lenina :(
          parent_locations.each do |pl|
            if locations[:area].present? && !district.match(/#{locations[:area]}/i) && pl.sublocations.where('title ilike ?', "%#{locations[:area]}%").count == 1
              parent = pl
            elsif locations[:street].present? && pl.sublocations.where('title ilike ?', "%#{locations[:street]}%").count == 1
              parent = pl
            end
            if parent.blank? && parent_locations.present?
              parent = parent_locations.where('title ilike ?', locations[:district]).first
            else
              parent = false
            end
          end
        end
      end
      result = { parent: superparent, district: parent }
      return result if parent.blank?

      keys = [:area, :street, :address]
      keys.delete(:area) if locations[:area].blank? || district.match(/#{locations[:area]}/i)
      keys.each do |ltype|
        break if locations[ltype].blank?
        temp = parent.sublocations.where('title ILIKE ?', "%#{locations[ltype]}%")
        if temp.count >= 1
          if temp.where('title ILIKE ?', "#{locations[ltype]}").count == 1
            temp = temp.where('title ILIKE ?', "#{locations[ltype]}").first
          else
            temp = temp.first
          end
        end
        if temp.present?
          result[ltype] = temp
          parent = temp
        end
      end
      result
    end

    def get_location loc_params
      street, address, district, region, parent = ''
      title = loc_params[:addr]
      district = Matcher.rename_district(loc_params[:dist])

      if loc_params[:atype] == 0
        #flats in rostov
        #parse string and get strings witch location titles
        street, address = DonrioParser.parse_flat title
        parent = 'г Ростов-на-Дону'
      else
        #houses and land
        area, street, address = DonrioParser.parse_house title
        parent = 'обл Ростовская'
      end
      lc = { parent: parent, district: district, area: area, street: street, address: address }
      result = find_locations_in_db(lc)

      if address.present? && result[:address].blank? && result[:street].present? && result[:street].location_type == 'street'
        create_address(parent: result[:street], title: address)
      end

      result.each {|k,v| result.delete(k) if v.blank?}
      result = normalize_locations result
      result
    end


    def create_address loc_params
      parent = Location.find(loc_params[:parent])
      address = parent.sublocations.create(title: loc_params[:title], location_type: :address)
      parent.loaded_resource!
      address
    end


    def normalize_locations locations
      nearest = locations[:address] || locations[:street] || locations[:area] || locations[:district] || locations[:parent]
      Location.parent_locations nearest
    end


    #TASK STARTS
    args.file ||= '/home/tea/RubymineProjects/nmir/public/import/first_test_donrio.xls'
    log = Logger.new './log/import-log.txt'
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
        phone = DonrioParser.parse_phone row, titles
        name = DonrioParser.parse_name row, titles

        #print "\nname=#{name}\n"

        adv = Advertisement.new
        contact = User.get_contact(phone: phone, name: name)

        if contact
          adv.user = contact
        else
          log.warn("could not recognize phone=#{phone} or find it in db for adv row number #{ worksheet.rows.index(row) }")
          next
        end

        adv.offer_type = DonrioParser.parse_offer_type row
        adv.adv_type = DonrioParser.parse_adv_type row
        adv.property_type = DonrioParser.parse_property_type row

        floor_from = DonrioParser.parse_floor_from row, titles
        adv.floor_from = floor_from if floor_from.present? && floor_from > 0
        floor_cnt_from = DonrioParser.parse_floor_cnt_from row, titles
        adv.floor_cnt_from = floor_cnt_from if floor_cnt_from.present? && floor_cnt_from > 0

        room_from = DonrioParser.parse_room row, titles
        adv.room_from = room_from if room_from.present? && room_from > 0

        space_from = DonrioParser.parse_space_from row, titles
        adv.space_from = space_from if space_from.present? && space_from > 0

        if titles['Sуч.Всотках'].present?
          outdoors_space_from = DonrioParser.parse_outdoors_space_from row, titles
          adv.outdoors_space_from = outdoors_space_from if outdoors_space_from.present? && outdoors_space_from > 0
        end
        adv.price_from = DonrioParser.parse_price row

        adv.category = DonrioParser.parse_category row, titles

        location = { dist: row[titles['Район']], addr: row[titles['Адрес']], atype: titles.keys.include?('Sуч.Всотках') ? 1 : 0 }
        locations = get_location(location)
        log.debug "locations = #{locations}\n"

        parsed = false
        locations.each { |l| parsed = true if l.location_type == 'address' }

        if locations.blank?
          log.warn "\nwe can't parse even region of #{adv} row line #{worksheet.rows.index(row)}\n"
          next
        end

        adv.comment = DonrioParser.parse_comment row, titles, parsed

        adv_params = { locations: locations, offer_type: adv.offer_type, category: adv.category, property_type: adv.property_type,
                       user_id: adv.user_id, price: adv.price_from }

        cadv = Advertisement.check_existence adv_params
        adv.locations = locations

        if !cadv
          if adv.save
            log.debug "\nWe are successfully created the advertisement #{adv.id}\n"
          else
            log.warn "\nCould not save advertisement #{adv.errors.full_messages}\n"
          end
        else
          log.debug "\nWe found same advertisement #{cadv.map(&:id)}\n"
        end
      end
    end

  end
end