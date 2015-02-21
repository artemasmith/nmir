class Matcher

  def self.rename_street street
    streets = {
        '' => ''
    }
    streets[street].blank? ? street : streets[street]
  end

  def self.rename_district district
    district = district.to_s.strip
    hash_list =
    {
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
      '40 лет Победы' => 'пр-кт 40-летия Победы '
    }
    hash_list[district].blank? ? district : hash_list[district]
  end
end