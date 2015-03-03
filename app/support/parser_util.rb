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



  def self.rename district
    district = district.to_s.strip
    hash_list =
    {
      'Область' => [Location.where(title: 'обл Ростовская').first],

      'Азов' => 'г Азов',
      'Аксай' => [Location.where(title: 'обл Ростовская').first, Location.where(title: 'р-н Аксайский').first, Location.where(title: 'г Аксай').first],

      'Азовский р-н' => 'р-н Азовский',
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
      'Шолохова' => 'пр-кт Шолохова',
    }
    value = hash_list[district]
    return (value.blank? ? ParserUtil.escape(district) : value) || ''
  end
end