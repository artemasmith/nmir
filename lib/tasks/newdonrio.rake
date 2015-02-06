#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :import do
  desc "Импорт информации из донрио"

  task(:donrio, [:file] => :environment) do |t, args|

    def find_locations_in_db locations
      parent = Location.where('title = ?', locations[:parent]).first
      result = { parent: parent }
      keys = [:district, :area, :street, :address]
      keys.delete(:area) if locations[:parent] == 'Ростов-на-Дону'
      keys.each do |ltype|
        break if locations[ltype].blank?
        temp = parent.sublocations.where('UPPER(title) ILIKE ?', "%#{locations[ltype].mb_chars.upcase.to_s}%").first
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

      result.each {|k,v| result.delete(k) if v.blank?}
      result = normalize_locations result
      result
    end


    def create_address loc_params
      parent = Location.find(loc_params[:parent])
      address = parent.sublocations.create(title: loc_params[:title], location_type: :address)
      address
    end


    def normalize_locations locations
      nearest = locations[:address] || locations[:street] || locations[:area] || locations[:district] || locations[:parent]
      Location.parent_locations nearest
    end


    #TASK STARTS
    args.file ||= '/home/kaa/test-book.xls'
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

        adv = Advertisement.new
        contact = User.get_contact(phone: phone)

        if contact
          adv.user = contact
        else
          log.warn("could not recognize phone=#{phone} or find it in db for adv row number #{ worksheet.rows.index(row) }")
          next
        end

        adv.offer_type = DonrioParser.parse_offer_type row
        adv.adv_type = DonrioParser.parse_adv_type row
        adv.property_type = DonrioParser.parse_property_type row

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
                       user_id: adv.user_id,comment: adv.comment, price: adv.price_from }

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