class ParserUtil

  def self.schedule(list)
    online = {0=>2.5301, 1=>1.2322, 2=>0.7568, 3=>0.4153, 4=>0.3361, 5=>0.4235, 6=>0.5792, 7=>1.1612, 8=>2.1448, 9=>4.2732, 10=>6.2541, 11=>6.4945, 12=>7.1093, 13=>7.2923, 14=>7.0464, 15=>6.9645, 16=>6.6503, 17=>5.7432, 18=>5.1694, 19=>5.0738, 20=>5.1066, 21=>5.6503, 22=>5.0574, 23=>4.3251}


    time = DateTime.now
    current_time = time.hour.hours + time.minute.minutes
    list.shuffle!
    adv_count = list.count
    total_online = online.values.inject(0){|sum, n| sum + n}

    (0..23).each do |hour|
      value = online[hour]

      count = adv_count.to_f * value / total_online
      if hour == 23
        count = list.count
      end

      count.ceil.times do
        minute = Random.rand(0..59)
        delay = hour.hours + minute.minutes - current_time
        if delay < 0
          delay = 1.day - delay.abs
        end
        row = list.pop
        yield delay, row if row
      end
    end


  end

  def self.escape str
    return str.to_s
         .gsub(/(?<=^|\s)(п|П)(о|О)(с(?=\s|[А-Я\/,\.]|$)|С(?=\s|[а-я\/,\.]|$))/, '')
         .gsub(/(?<=^|\s)(о|О)(с|С)(т(?=\s|[А-Я\/,\.]|$)|Т(?=\s|[а-я\/,\.]|$))/, '')
         .gsub(/(?<=^|\s)(у|У)(л(?=\s|[А-Я\/,\.]|$)|Л(?=\s|[а-я\/,\.]|$))/, '')
         .gsub(/(?<=^|\s)(с|С)(т(?=\s|[А-Я\/,\.]|$)|Т(?=\s|[а-я\/,\.]|$))/, '')
         .gsub(/(?<=^|\s)(д|Д)(н|Н)(т(?=\s|[А-Я\/,]|$)|Т(?=\s|[а-я\/,]|$))/, '')
         .gsub(/(?<=^|\s)(с|С)(н|Н)(т(?=\s|[А-Я\/,]|$)|Т(?=\s|[а-я\/,]|$))/, '')
         .gsub(/(?<=^|\s)(с|С)(т(?=\s|[А-Я\/,]|$)|Т(?=\s|[а-я\/,]|$))/, '')
         .gsub(/(?<=^|\s)(к|К)(п(?=\s|[А-Я\/,]|$)|П(?=\s|[а-я\/,]|$))/, '')
         .gsub(/(?<=^|\s)(ж|Ж)(к(?=\s|[А-Я\/,]|$)|К(?=\s|[а-я\/,]|$))/, '')
         .gsub(/(?<=^|\s)(р|Р)\-(н(?=\s|[А-Я\/,]|$)|Н(?=\s|[а-я\/,]|$))/, '')
         .gsub(/(?<=^|\s)(г(?=\s|[А-Я\/,\.]|$))/, '')
         .gsub(/(?<=^|\s)(х(?=\s|[А-Я\/,\.]|$))/, '')
         .gsub(/(?<=^|\s)(с(?=\s|[А-Я\/,\.]|$))/, '')
         .gsub(/(?<=^|\s)(п(?=\s|[А-Я\/,\.]|$))/, '')
         .gsub(/(?<=^|\s)(д(?=\s|[А-Я\/,\.]|$))/, '')
         .gsub(/\./i, '')
         .strip
  end



  def self.rename field, name
    name = name.to_s.strip
    hash_list =
    {
      :address =>
        {
          'Область' => [Location.where(title: 'обл Ростовская').first],

          'Азов' => 'г Азов',
          'Аксай' => [Location.where(title: 'обл Ростовская').first, Location.where(title: 'р-н Аксайский').first, Location.where(title: 'г Аксай').first],

          'Азовский р-н' => 'р-н Азовский',
          'Аксакйский р-н' => 'р-н Аксайский',
          'Аксайский р-н' => 'р-н Аксайский',
          'Батайск' => 'г Батайск',

          '1 Ордж.' => 'Орджоникидзе',
          '2 Ордж.' => 'Орджоникидзе',
          '1 Ордж' => 'Орджоникидзе',
          '2 Ордж' => 'Орджоникидзе',
          'Зооп.' => 'Зоопарк',
          'Военв.' => 'Военвед',
          'Алекс.' => 'Александровка',
          'Ленина' => 'Ленина площадь',
          'Левенц' => 'Ливенцовка',
          'Неклиновский р-н' => 'р-н Неклиновский',
          'Мясниковский р-н' => 'р-н Мясниковский',
          'Кагальницкий р-н' => 'р-н Кагальницкий',
          'Рост. море' => 'Ростовское море',
          '40 лет Победы' => 'пр-кт 40-летия Победы',
          '40 Лет Победы' => 'пр-кт 40-летия Победы',
          'Шолохова' => 'пр-кт Шолохова',
          'Добровольского' => 'ул Добровольского',
          'Добровольского' => 'ул Добровольского',
          'п. Койсуг' => 'п Койсуг',

        },
      :char =>
        {
          'отл' => 'отличное',
          'стройвар' => 'строй вариант',
          'хор' => 'хорошее',
          'незавер' => 'незавершенное',
          'удовл' => 'удовлетворительно'
        },
      :windows =>
        {
          'м/пласт' => 'металопластик',
          'дер' => 'деревянные',
        },
      :balcony =>
        {
          'тепл' => 'теплый',
          'незаст' => 'незастекленный',
          'нет' => 'нет'
        },
      :bath =>
        {
          'разд' => 'раздельный',
          'совм' => 'совмещенный'
        },
      :walls =>
        {
          'мон' => 'монолит',
          'пан' => 'панель',
          'кир' => 'кирпич',
          'бло' => 'блок',
          'шла' => 'шлакоблок',
          'газ' => 'газобетон',
          'сам' => 'сам',
          'кам' => 'камень',
          'пен' => 'пенобетон',
          'щел' => 'щел'

        },
      :plumbing =>
        {
          'местн' => 'местная',
          'центр' => 'центральная'
        },
      :water =>
        {
          'центр' => 'центральная',
          'п/меж' => 'п/меж',
          'в/дв' => 'в/дв',
          'на уч' => 'на участке',
          'скваж' => 'скважина',
          'в/дом' => 'в/дом'
        },
      :gas =>
        {
          'центр' => 'центральный',
          'по ме' => 'по ме'
        },
      :land_status =>
        {
          'приват' => 'приватизирована'
        },
      :renovation =>
        {
          'евро' => 'евро ремонт',
          'обычн' => 'обычный'
        },
      :blueprint =>
        {
          'бабочка' => 'бабочка',
          'разд' => 'раздельный',
          'смежн' => 'смежный',
          'вагон' => 'вагон',
          'смежИзол' => 'смежный-Изолированный',
          '1+2' => '1+2',
          'распаш' => 'распашонка'
        },
      :standalone =>
        {
          'отд/стоящ' => 'отдельно стоящий',
          'встр/торец' => 'встроенный в торец',
          'встр/тыл' => 'встроенный в тыл',
        },
      :road =>
        {
          'асф' => 'асфальтированная',
          'щебень' => 'щебень',
          'тырса' => 'тырса',
          'грунт' => 'грунтовая',
          'плиты' => 'плиты'

        }

    }
    value = hash_list[field].present? ? hash_list[field][name] : name
    value = 'не указано' if name == '?'
    return (value.blank? ? ParserUtil.escape(name) : value) || ''
  end



  def self.find_child parent, title, type = :all
    parent.children_locations(type).where('title ilike ?', "%#{title}%").first
  end

  def self.find_address_locations_in_db parent, path, result
    return result, false if path.blank?

    correct_path_first = ParserUtil.rename(:address, path.first)
    return nil, false unless correct_path_first.is_a?(String)
    sub_location = find_child parent, correct_path_first
    return nil, false if sub_location.blank?
    result << sub_location


    correct_path_second = ParserUtil.rename(:address, path.second)
    return sub_location, false unless correct_path_second.is_a?(String)

    if sub_location.street? && path.second.present? && correct_path_second.to_i > 0
      sub_sub_location = sub_location.children_locations.where(title: correct_path_second.to_i.to_s).first ||
          create_address(parent: sub_location, title: correct_path_second.to_i.to_s)
      result << sub_sub_location
      return nil, true
    end

    return sub_location, false
  end

  def self.find_locations_in_db parent_name, original_district, original_address, result = []

    district_name = ParserUtil.rename(:address, original_district)
    address_name = ParserUtil.rename(:address, original_address)

    if district_name.is_a?(String) || district_name.is_a?(NilClass)
      superparent = Location.where(title: parent_name).first

      return result, [original_district, original_address].delete_if{|e| e.blank?}.join(', ') if district_name.blank?
      if superparent.city?
        district = find_child(superparent, district_name, :admin_area) ||
            find_child(superparent, district_name, :non_admin_area)
      else
        district = find_child(superparent, district_name)
      end

      return result, [original_district, original_address].delete_if{|e| e.blank?}.join(', ') if district.blank?

      result << superparent
      result << district
    else
      result = district_name
      district = result.last
    end

    if address_name.is_a?(String) || address_name.is_a?(NilClass)

      return result, original_address if address_name.blank?

      address_name_list = address_name.split('/').delete_if{ |e| e.blank? }
      path_list = address_name_list.first.split(',').map{ |e| e.to_s.strip }.delete_if{ |e| e.blank? } if address_name_list.first.present?
      addition_path_list = address_name_list.second.split(',').map{ |e| e.to_s.strip }.delete_if{ |e| e.blank? } if address_name_list.second.present?

      address, parsed = self.find_address_locations_in_db district, path_list, result
      if address.blank?
        return result, parsed ? nil : original_address
      end

      address, parsed = self.find_address_locations_in_db address, addition_path_list, result
      if address.blank?
        return result, parsed ? nil : original_address.split('/').delete_if{ |e| e.blank? }.second
      end
    else
      result << address_name
    end

    return result, nil
  end

  def self.get_location loc_params
    district = loc_params[:dist]
    address = loc_params[:addr]


    ro = Location.where(title: 'обл Ростовская').first
    result, unparsed = self.find_locations_in_db('г Ростов-на-Дону', district, address, [ro])
    result, unparsed =  self.find_locations_in_db('обл Ростовская', district, address) if result == [ro]

    return (result.presence || [ro]), unparsed
  end


  def self.create_address attr
    parent = attr[:parent]
    address = parent.sublocations.create(title: attr[:title], location_type: :address)
    parent.loaded_resource!
    address
  end


end