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
        street, street2, address = ''

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

        firststreet = rostov.children_locations.where('UPPER(title) LIKE ?', street)
        if firststreet.present? && address
          address = address.mb_chars.upcase.to_s
          address = firststreet.children_locations.where('UPPER(title) LIKE ?', address)
        end
        #what should I do with street2 and street 3???

      else
        #houses and land


      end
    end

    def get_contact str

    end

    def get_date str

    end

    def prepare_char str

    end

    def rename_district dist
      dist = dist.strip
      hash_list =
          {'?' => nil,
           'пригород' => nil,
           'Нахич' => 'Нахич',
           'Вонвед' => 'Военвед',
           'Вонв.' => 'Военвед',
           'Лениа' => 'Ленина',
           '1 Ордж.' => '1-й Орджоникидзе',
           '2 Ордж.' => '2-й Орджоникидзе',
           'Пригород' => 'Ростов-на-Дону',
           '1 Ордж' => '1-й Орджоникидзе',
           '2 Ордж' => '2-й Орджоникидзе',
           'Рост. море' => 'Ростовское море',
           'Аксайскийр-н' => 'Аксайский р-н',
           'Аэроп.' => 'Аэропорт',
           'Аксай' => 'Аксайский р-н',
           'Алекс' => 'Александровский р-н',
           'Обл' => 'Ростовская обл.',
           'Область' => 'Ростовская обл.',
           'Рост море' => 'Ростовское море',
           'Рост.море' => 'Ростовское море',
           'Ц ентр' => 'Центр',
           '1 Ордж.' => '1-й Орджоникидзе',
           '2 Ордж.' => '2-й Орджоникидзе',
           'Рост... море' => 'Ростовское море',
           'РИЖТ' => 'Ленина',
           'Рост. Море' => 'Ростовское море'
          }
      hash_list[dist]
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

          location = { addr: row[titles['Район']], dist: row[titles['Адрес']], atype: adv.property_type == :flat ? 0 : 1 }
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