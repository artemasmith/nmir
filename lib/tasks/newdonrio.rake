#encoding: utf-8
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
namespace :multilisting do
  desc "Импорт информации из донрио"

  task(:newdonrio, [:file, :user_id, :type_donrio] => :environment) do |t, args|

    def get_location loc_params
      if loc_params[:atype] == 0
        title, district = loc_params[:loc].split('|')
        street = title.split('/')
        rostov = Location.find_by_title('Ростов-на-Дону')

        lstreet = rostov.children.where('UPPER(title) LIKE ?', street)
      else

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
           'Вонвед' => 'Военвед',
           'Лениа' => 'Ленина',
           '1 Ордж.' => '1-й Орджоникидзе',
           '2 Ордж.' => '2-й Орджоникидзе',
           'Пригород' => 'Ростов-на-Дону',
           '1 Ордж' => '1-й Орджоникидзе',
           '2 Ордж' => '2-й Орджоникидзе',
           'Рост. море' => 'Ростовское море',
           'Аксайскийр-н' => 'Аксайский р-н',
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

          location = { loc: row[titles['Район']] + '|' + row[titles['Адрес']], atype: adv.property_type == :flat ? 0 : 1 }
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