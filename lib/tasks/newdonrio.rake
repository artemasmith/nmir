#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :multilisting do
  desc "Импорт информации из донрио"

  task(:newdonrio, [:file] => :environment) do |t, args|

    def get_location loc_params
      if loc_params[:atype] == 0
        #flats in rostov
        title = loc_params[:addr]
        street, street2, address, village, district = ''

        #fucking regexp too complicated and eat all cpu:(

        title = title.split('/')
        if title.count == 1
          #street and house or street only
          title = title.split(',')
          street = title[0]
          if title.count == 2
            #only street
            address  = title[1]
          end
        elsif title.count == 2
          #street/street or street, house/house
          if title[1].match /^\d+[[:alpha:]]{0,1}$/
            #street, house/house
            street = title[0].split(',')[0]
            address = title[0].split(',')[1] + '/' + title[1]
          elsif title[1].match /^\d*\s*[[:alpha:]]+$/
            #street/street or street,house/street
            #if we have 2 streets we save only one?
            temp = title[0].split(',')
            if temp.count == 2
              street = temp[0]
              address = temp[1]
            else
              street = title[0]
              street2 = title[1]
              address = nil
            end
          end
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
        street = Matcher.rename_street(street).mb_chars.upcase.to_s
        rostov = Location.find_by_title('Ростов-на-Дону')
        district = rostov.sublocations.where('UPPER(title) LIKE ?', Matcher.rename_district(loc_params[:dist].strip).mb_chars.upcase.to_s).first

        street = rostov.sublocations.where('UPPER(title) LIKE ?', street).first
        if street.present? && address
          retaddress = street.sublocations.where('UPPER(title) LIKE ?', address.mb_chars.upcase.to_s.strip).first
          #if there is no house number - we will create it lately
          address = retaddress if retaddress.present?
        end
        #what should I do with street2 and street 3???

      else
        #houses and land
        rostovobl = Location.find_by_title('Ростовская область')
        region = Matcher.rename_district(loc_params[:dist].strip).mb_chars.upcase.to_s
        print "\n in get_location region before search = #{region}\n"
        region = rostovobl.sublocations.where("UPPER(title) LIKE ?", region).first
        print "\n in get_location region after search = #{region}\n"

        #if we cant parse even a region
        return false if region.blank?

        title = loc_params[:addr].split('/')
        print "\n title in get_location= #{title} \n"
        if title.count == 2
          #dist/street dist/street, house  dist/street house
          village = region.sublocations.where('UPPER(title) LIKE ?', title[0].mb_chars.upcase.to_s).first
          if village.present?
            temp = title[1].split(',')
            if temp.count == 2
              street = Matcher.rename_street(temp[0].strip).mb_chars.upcase.to_s
              address =  Matcher.rename_street(temp[1].strip).mb_chars.upcase.to_s

              print " address = #{address} street = #{street}\n"
            else
              street = Matcher.rename_street(title[1].strip).mb_chars.upcase.to_s
            end
            if temp.count == 2
              # village/street, house
              street = village.sublocations.where('UPPER(title) LIKE ?', street).first
              address = street.sublocations.where('UPPER(title) LIKE ?', address).first if street.present? && address.present?
            elsif temp.count == 1
              #vilage/street
              street = village.sublocations.where('UPPER(title) LIKE ?', street).first
            end
          end
        end
      end
      result = { district: district, village: village, street: street, address: address }
      #????
      result.each {|k,v| result.delete(k) if v.blank?}
      result
    end

    def get_contact cinfo
      phone = Phone.where('number = ?',Phone.normalize(cinfo[:phone])).first
      if phone.present?
        return phone.user
      else
        user = User.where('name Like ?', cinfo[:name].strip).first
        if user.present?
          if user.phones.where('number = ?', Phone.normalize(cinfo[:phone])).blank?
            user.phones.create(original: cinfo[:phone])
          end
          return user
        else
          #what should we do if there is no user or phone?
          user = User.create(email: "#{cinfo[:name]}#{cinfo[:phone]}@mail.ru", password: "#{Time.now}+#{Time.now}", name: cinfo[:name], role: 0)
          user.phones.create(original: cinfo[:phone])
          return user
        end
      end

    end

    def get_date str

    end

    def prepare_char str
      res = str.index /\d{2}\.\d{2}\.\d{4}/
      res = res.present? ? res = str[0..res-1] : str
      res
    end

    #should return false if we didnt find same adv
    def check_existance adv_params
      nearest_location = adv_params[:locations][:address] || adv_params[:locations][:street] ||
          adv_params[:locations][:village] || adv_params[:locations][:district]

      #first we find all advs in granted locations with our property_avd
      pre_advs = Advertisement.joins(:locations).where('locations.title = ? AND advertisements.offer_type = ? AND advertisements.category = ? AND user_id = ?',
                                                       nearest_location.title, adv_params[:offer_type], adv_params[:category], adv_params[:user_id])
      if pre_advs.blank?
        return false
      else
        pre_advs = pre_advs.where('comment like ?', adv_params[:comment])
        if pre_advs.count > 0
          print "sorry, we found simular advertisement(s) #{pre_advs.map(&:id).join(';')}"
          return pre_advs
        else
          return false
        end
      end
    end


    #TASK STARTS
    args.file ||= '/home/kaa/test-book.xls'
    adv = {}
    titles = {}
    workbook = Spreadsheet.open('/home/kaa/test-book.xls').worksheets
    workbook.each do |worksheet|
      titles.clear
      worksheet.each do |row|
        if titles.empty?
          row.each_with_index do |column, index|
            titles[column] = index
          end
          next
        end

        next if row.count == 0 || row.compact.count == 0

        row.each_with_index do |col, index|
          #here we are looking for client info
          contactrow = row[titles['Тел контанк']].gsub(/[^[:word:]]/, '')
          name = contactrow.gsub /[^[:alpha:]]/, ''
          phone = contactrow.gsub /[[:alpha:]]/, ''
          print "name = #{name} phone = #{phone}\n"

          if name.blank? || phone.blank?
            print "There is no name or phone for adv index #{index}, #{name} #{phone}\n"
            next
          end

          adv = Advertisement.new
          adv.user = get_contact(name: name, phone: phone)
          print "user = #{adv.user}"

          adv.offer_type = :sale
          adv.adv_type = 1
          adv.property_type = 1

          adv.price_from = row[1].to_i
          print "adv.price_from #{adv.price_from}\n"

          har = row[titles['Хар']]
          if har.match /участок/i
            adv.category = :land
          elsif har.match /дом/i
            adv.category = :house
          else
            adv.category = :flat
          end
          print "category #{adv.category}\n"

          location = { dist: row[titles['Район']], addr: row[titles['Адрес']], atype: adv.category == :flat ? 0 : 1 }
          locations = get_location(location)

          if locations.blank?
            print "\nwe cant parse even region of #{adv} #{prepare_char(row[titles['Хар']])}\n"
            next
          end

          adv.comment = %Q(цена: #{row[1]} т.р., район: #{row[titles['Район']]},
               адрес: #{row[titles['Адрес']]}, этажей: #{row[titles['Эт.']]}, комнат: #{row[titles['ком.']]},
                площадь: #{row[titles['Площадь']]}, коментарий: #{prepare_char(row[titles['Хар']])})
          if titles.keys.find('Sуч.Всотках')
            adv.comment += ", площадь-участка: #{row[titles['Sуч.Всотках']]}"
          end

          adv_params = { locations: locations, offer_type: adv.offer_type, category: adv.category, user_id: adv.user_id,
          comment: adv.comment }

          cadv = check_existance adv_params
          adv.locations = locations.map{ |k,l| l }

          if !cadv
            if adv.save
              print "\nWe are successfully created the advertisement #{adv}\n"
            else
              print "\nCould not save advertisement #{adv.errors.full_messages}\n"
            end
          else
            print "\nWe found same advertisement #{cadv}\n"
          end
        end
      end
    end

  end
end