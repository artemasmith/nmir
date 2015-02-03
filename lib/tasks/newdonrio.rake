#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :multilisting do
  desc "Импорт информации из донрио"

  task(:newdonrio, [:file] => :environment) do |t, args|

    def get_location loc_params
      street, street2, address, village, district, region = ''
      if loc_params[:atype] == 0
        #flats in rostov
        title = loc_params[:addr]

        #fucking regexp too complicated and eat all cpu:(

        title = title.split('/')
        #print "title = #{title} title count= #{title.count}\n"
        if title.count == 1
          #street and house or street only
          title = title[0].split(',')
          street = title[0]
          #print "first section title count==1 street=#{street}"
          if title.count == 2
            #street and house
            address  = title[1]
           # print "title(,) count ==2 address= #{address} \n"
          end
        elsif title.count == 2
          #print "we are in title count == 2"
          #street/street or street, house/house
          if title[1].match /^\d+[[:alpha:]]{0,1}$/
            #street, house/house
            street = title[0].split(',')[0]
            address = title[0].split(',')[1] + '/' + title[1]
           # print "first match"
          elsif title[1].strip.match /^\d*\s*[[:alpha:]]+$/
            #street/street or street,house/street
            #if we have 2 streets we save only one?
            temp = title[0].split(',')
            #print "second match temp=#{temp}"
            if temp.count == 2
              street = temp[0]
              address = temp[1]
             # print "temp.count =2 "
            else
              street = title[0]
              street2 = title[1]
              address = nil
              #print "street/street str = #{street} #{street2}"
            end
            #print "second main if street #{street} address #{address}"
          end
          #print "may it be? no one matcher.. street = #{street}"
        elsif title.count == 3
          #street, house/house/street or street,house/street/street
          street = title[0].split(',')[0]
          if title[1].match /^\d+[[:alpha:]]{0,1}$/
            #street, house/house/street
            address = title[0].split(',')[1] + '/' + title[1] if  title[0].split(',').count == 2
            street2 = title[2]
          else
            address = title[0].split(',')[1] if  title[0].split(',').count == 2
            street2 = title[1]
            street3 = title[2]
          end
        end
        street = Matcher.rename_street(street.strip).mb_chars.upcase.to_s
        rostov = Location.find_by_title('Ростов-на-Дону')
        district = rostov.sublocations.where('UPPER(title) LIKE ?', Matcher.rename_district(loc_params[:dist].strip).mb_chars.upcase.to_s).first
        #print "street #{street} \n"

        street = district.sublocations.where('UPPER(title) LIKE ?', street).first
        #print "location street #{street}"
        if street.present? && address
          retaddress = street.sublocations.where('UPPER(title) LIKE ?', address.mb_chars.upcase.to_s.strip).first
          #if there is no house number - we will create it lately
          if retaddress.present?
            address = retaddress
          else
            address = create_address(parent: street.id, title: address.strip) if street.location_type == 'street'
          end
        else
          address = nil
        end
        #what should I do with street2 and street 3???
        #print "#{address}"

      else
        #houses and land
        rostovobl = Location.find_by_title('Ростовская область')
        region = Matcher.rename_district(loc_params[:dist].strip).mb_chars.upcase.to_s
        #print "\n in get_location region before search = #{region}\n"
        region = rostovobl.sublocations.where("UPPER(title) LIKE ?", region).first
        #print "\n in get_location region after search = #{region}\n"

        #if we cant parse even a region
        return false if region.blank?

        title = loc_params[:addr].split('/')
        #print "\n title in get_location= #{title} \n"
        if title.count == 2
          #dist/street dist/street, house  dist/street house
          village = region.sublocations.where('UPPER(title) LIKE ?', title[0].mb_chars.upcase.to_s).first
          if village.present?
            temp = title[1].split(',')
            if temp.count == 2
              street = Matcher.rename_street(temp[0].strip).mb_chars.upcase.to_s
              address =  Matcher.rename_street(temp[1].strip).mb_chars.upcase.to_s

              #print " address = #{address} street = #{street}\n"
            else
              street = Matcher.rename_street(title[1].strip).mb_chars.upcase.to_s
            end
            if temp.count == 2
              # village/street, house
              street = village.sublocations.where('UPPER(title) LIKE ?', street).first
              if street.present? && address.present?
                raddress = street.sublocations.where('UPPER(title) LIKE ?', address).first
                if raddress.blank? && street.location_type == 'street'
                  address = create_address(title: address.strip, parent: street.id)
                else
                  address = raddress
                end
              end
            elsif temp.count == 1
              #vilage/street
              street = village.sublocations.where('UPPER(title) LIKE ?', street).first
            end
          end
        else
          #street, house or street
          temp = title[0].split(',')
          if temp.count == 2
            #VERY WET CODE!!!!!!!!!!!!!!!!!!!!!!!!!!but i just want to go to sleep
            #street, house
            street = Matcher.rename_street(temp[0].strip).mb_chars.upcase.to_s
            street = region.sublocations.where('UPPER(title) LIKE ?', street).first
            address =  Matcher.rename_street(temp[1].strip).mb_chars.upcase.to_s
            if street.present? && address.present?
              raddress = street.sublocations.where('UPPER(title) LIKE ?', address).first
              if raddress.blank? && street.location_type == 'street'
                address = create_address(title: address.strip, parent: street.id)
              else
                address = raddress
              end
            end
          end
        end
      end
      result = { district: district, village: village, street: street, address: address, region: region }
      #????
      result.each {|k,v| result.delete(k) if v.blank?}
      result
    end


    def create_address loc_params
      parent = Location.find(loc_params[:parent])
      address = parent.sublocations.create(title: loc_params[:title], location_type: :address)
      address
    end

    def prepare_char str
      res = str.index /\d{2}\.\d{2}\.\d{4}/
      res = res.present? ? res = str[0..res-1] : str
      res
    end

    def normalize_locations locations
      nearest = locations[:address] || locations[:street] || locations[:village] || locations[:district]
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
        contactrow = row[titles['Тел контанк']].gsub(/[^[:word:]]/, '')
        name = contactrow.gsub /[^[:alpha:]]/, ''
        phone = contactrow.gsub /[[:alpha:]]/, ''

        adv = Advertisement.new
        contact = User.get_contact(name: name, phone: phone)

        if contact
          if contact.class == User
            adv.user = contact
          else
            adv.phone = contact
          end
        else
          log.debug("could not recognize phone for adv row number #{ worksheet.rows.index(row) }")
          next
        end
        #print "user = #{adv.user}"

        adv.offer_type = :sale
        adv.adv_type = :offer
        adv.property_type = :commerce

        adv.price_from = row[1].to_i
        #print "adv.price_from #{adv.price_from}\n"

        har = row[titles['Хар']]
        if har.match /участок/i
          adv.category = :land
        elsif har.match /дом/i
          adv.category = :house
        else
          adv.category = :flat
        end
        #print "category #{adv.category}\n"

        location = { dist: row[titles['Район']], addr: row[titles['Адрес']], atype: titles.keys.include?('Sуч.Всотках') ? 1 : 0 }
        log.debug "\nlocation = #{location}\n"
        locations = get_location(location)
        log.debug "locations = #{locations}\n"

        if locations.blank?
          log.debug "\nwe can't parse even region of #{adv} row line #{worksheet.rows.index(row)}\n"
          next
        end

        adv.comment = %Q(цена: #{row[1]} т.р., район: #{row[titles['Район']]},
             адрес: #{row[titles['Адрес']]}, этажей: #{row[titles['Эт.']]}, комнат: #{row[titles['ком.']]},
              площадь: #{row[titles['Площадь']]}, коментарий: #{prepare_char(row[titles['Хар']])})
        #print "titles #{titles}"
        #print "advcomment #{adv.comment}\n"
        if titles.keys.include?('Sуч.Всотках')
          adv.comment += ", площадь-участка: #{row[titles['Sуч.Всотках']]}"
        end

        adv_params = { locations: locations, offer_type: adv.offer_type, category: adv.category, property_type: adv.property_type,
                       user_id: adv.user_id,comment: adv.comment, price: adv.price_from }

        cadv = Advertisement.check_existence adv_params
        #print "\n\nCADV #{cadv}\n\n"
        adv.locations = normalize_locations locations

        if !cadv
          if adv.save
            log.debug "\nWe are successfully created the advertisement #{adv.id}\n"
          else
            log.debug "\nCould not save advertisement #{adv.errors.full_messages}\n"
          end
        else
          log.debug "\nWe found same advertisement #{cadv.map(&:id)}\n"
        end
      end
    end

  end
end