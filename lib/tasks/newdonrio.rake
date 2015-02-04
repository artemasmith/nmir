#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :import do
  desc "Импорт информации из донрио"

  task(:donrio, [:file] => :environment) do |t, args|

    def parse_flat title
      title = title.split('/')
      title.each {|s| s.strip! }
      #print "title = #{title} title count= #{title.count}\n"
      if title.count == 1
        #street and house or street only
        title = title[0].split(',')
        title.each {|s| s.strip! }
        street = title[0]
        #print "first section title count==1 street=#{street}"
        if title.count == 2
          #street and house
          address  = title[1]
          # print "title(,) count ==2 address= #{address} \n"
        end
      elsif title.count == 2
        #street/street or street, house/house
        if title[1].match /^\d+[[:alpha:]]{0,1}$/
          #street, house/house
          street = title[0].split(',')[0].strip
          address = title[0].split(',')[1] + '/' + title[1]
          # print "first match"
        elsif title[1].match /^\d*\s*[[:alpha:]]+$/
          #street/street or street,house/street
          #if we have 2 streets we save only one?
          temp = title[0].split(',')
          temp.each {|s| s.strip! }
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

      #print "#{address}"
      street = street.present? ? Matcher.rename_street(street).mb_chars.upcase.to_s : nil
      address = address.present? ? address.mb_chars.upcase.to_s : nil
      #print "street= #{street} address=#{address}\n"
      return street, address
    end

    def parse_house title
      title = title.split('/')
      title.each {|s| s.strip! }
      district, area, street, street2, address = ''
      #print "\n title in get_location= #{title} \n"
      if title.count == 3
        #area/street/street | area/street/address (very rarely)
        area = title[0]
        street = title[1]
        #print "title[2] = #{title[2]} \n"
        title[2].match /^\d+[[:alpha:]]{0,1}$/ ? address = title[2].strip : street2 = title[2].strip
      elsif title.count == 2
        #area/area | area/address | area/street, address
        if title[1].split(',').count == 2
          #area/street, house
          sub_district = title[0]
          street = title[1].split(',')[0].gsub(/^(ул){0,1}\.{0,1}/, '').strip
          address = title[1].split(',')[1].strip
        # /(ул){0,1}\.{0,1}\s*[[:alpha:]]+/
        elsif title[1].split(',').count == 1
          #area/street area/street address
          area = title[0]
          street = title[1].gsub(/^(ул){0,1}\.{0,1}/, '').gsub(/\d+[[:alpha:]]{0,1}$/, '').strip
          address = title[1].match(/\d+[[:alpha:]]{0,1}$/).to_s
        end
      else
        temp = title[0].split(',')
        temp.each{ |s| s.strip! }
        if temp.count == 3
          #area,street,address
          area = temp[0].strip
          street = temp[1].gsub(/^(ул){0,1}\.{0,1}/, '').strip
          address = temp[2].strip
        elsif temp.count == 2
          #area, address | area, street address | street, address
          area = temp[0]
          street = temp[1].gsub(/^(ул){0,1}\.{0,1}/, '').gsub(/\d+[[:alpha:]]{0,1}$/, '').strip
          address = temp[1].match(/\d+[[:alpha:]]{0,1}$/).to_s
        else
          #area
          area = title[0].strip
        end
      end
      area = area.present? ? area.mb_chars.upcase.to_s : nil
      street = street.present? ? Matcher.rename_street(street).mb_chars.upcase.to_s : nil
      address = address.present? ? address.mb_chars.upcase.to_s : nil
      #print "area = #{area} street= #{street} address=#{address}\n"
      return area, street, address
    end


    def find_locations_in_db locations
      #print "locations #{locations}"
      parent = Location.where('title = ?', locations[:parent]).first
      result = {}
      keys = [:district, :area, :street, :address]
      keys.delete(:area) if locations[:parent] == 'Ростов-на-Дону'
      #[:district, :area, :street, :address].each { |k| keys << k if locations[k].present? }
      keys.each do |ltype|
        break if locations[ltype].blank?
        temp = parent.sublocations.where('UPPER(title) LIKE ?', locations[ltype].mb_chars.upcase.to_s).first
        if temp.present?
          result[ltype] = temp
          parent = temp
        end
      end
      #print "result in find_locations_in_db #{result}\n"
      result
    end

    def get_location loc_params
      street, street2, address, village, district, region, parent = ''
      title = loc_params[:addr]
      district = Matcher.rename_district(loc_params[:dist])

      if loc_params[:atype] == 0
        #flats in rostov
        #parse string and get strings witch location titles
        street, address = parse_flat title
        #find locations by title in db
        parent = 'Ростов-на-Дону'
      else
        #houses and land
        area, street, address = parse_house title
        parent = 'Ростовская область'
      end
      lc = { parent: parent, district: district, area: area, street: street, address: address }
      #print "lc = #{lc}"
      result = find_locations_in_db(lc)
      #print "\nresult #{result}\n"

      return false if result[:district].blank?

      #result = { district: district, village: village, street: street, address: address, region: region }
      #????
      result.each {|k,v| result.delete(k) if v.blank?}
      #print "\nresult = #{result}\n"
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
      nearest = locations[:address] || locations[:street] || locations[:area] || locations[:district]
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
        #log.debug "\nlocation = #{location}\n"
        locations = get_location(location)
        #log.debug "locations = #{locations}\n"

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