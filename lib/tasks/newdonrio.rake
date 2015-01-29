#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :multilisting do
  desc "Импорт информации из донрио"

  task(:newdonrio, [:file, :user_id, :type_donrio] => :environment) do |t, args|

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
        street = street.mb_chars.upcase.to_s
        rostov = Location.find_by_title('Ростов-на-Дону')
        district = rostov.sublocations.where('UPPER(title) LIKE ?', loc_params[:dist].strip.mb_chars.upcase.to_s).first

        street = rostov.sublocations.where('UPPER(title) LIKE ?', street).first
        if street.present? && address
          retaddress = street.sublocations.where('UPPER(title) LIKE ?', address.mb_chars.upcase.to_s).first
          #if there is no house number - we will create it lately
          address = retaddress if retaddress.present?
        end
        #what should I do with street2 and street 3???

      else
        #houses and land
        rostovobl = Location.find_by_title('Ростовская область')
        region = loc_params[:dist].strip.mb_chars.upcase.to_s
        region = rostovobl.sublocations.where("UPPER(title) LIKE ?", region.mb_chars.upcase.to_s).first

        title = loc_params[:addr].split('/')
        if title.count == 2
          #dist/street dist/street, house  dist/street house
          village = region.sublocations.where('UPPER(title) LIKE ?', title[0].mb_chars.upcase.to_s).first
          if village.present?
            temp = title[1].split(',')
            if temp.count == 2
              # village/street, house
              street = village.sublocations.where('UPPER(title) LIKE ?', temp[0].mb_chars.upcase.to_s).first
              address = street.sublocations.where('UPPER(title) LIKE ?', temp[1].mb_chars.upcase.to_s).first if street.present?
            elsif temp.count == 1
              #vilage/street
              street = village.sublocations.where('UPPER(title) LIKE ?', title[1].mb_chars.upcase.to_s).first
            end
          end
        end
      end
      result = { district: district, village: village, street: street, address: address }
      #????
      result.each {|k,v| result.delete(k) if v.blank?}
      return result
    end

    def get_contact str

    end

    def get_date str

    end

    def prepare_char str

    end

    #should return false if we didnt find same adv
    def check_existance adv_params

    end


    #TASK STARTS

    args.with_defaults(:file => '/home/tea/Downloads/донрио дома уч041213 (5).xls')
    args.with_defaults(:user_id => '1')
    args.with_defaults(:type_donrio => '1')
    user = User.find(args.user_id)

    adv = {}
    titles = {}
    workbook = Spreadsheet.open(args.file).worksheets
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
          contactrow = row[worksheet.rows.count-1].gsub(/[^[:word:]]/, '')
          name = contactrow.gsub /[^[:alpha:]]/, ''
          phone = contactrow.gsub /[[:alpha:]]/, ''

          if name.blank? || phone.blank?
            print "There is no name or phone for adv index #{index}, #{name} #{phone}"
            next
          end

          adv = Advertisement.new
          adv.user = get_contact(name: name, phone: phone)

          adv.offer_type = :sale

          adv.price_from = row[1]

          har = row[titles['Хар']]
          if har.match /участок/i
            adv.property_type = :land
          elsif har.match /дом/i
            adv.property_type = :house
          else
            adv.property_type = :flat
          end

          location = { dist: row[titles['Район']], addr: row[titles['Адрес']], atype: adv.property_type == :flat ? 0 : 1 }
          adv.locations = get_location(location)

          cadv = check_existance adv

          if !cadv
            if titles.keys.find('Sуч.Всотках')
              adv.comment = %Q(цена: #{row[1]} т.р.,)
            else
              adv.comment = %Q(цена: #{row[1]} т.р., комнат: #{})
            end
            if adv.save
              print "We are successfully created the advertisement #{adv}"
            else
              print "Could not save advertisement #{adv.errors.full_messages}"
            end
          else
            print "We found same advertisement #{cadv.id}"
          end
        end
      end
    end

  end
end