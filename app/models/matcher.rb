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
      'Аксай' => 'г Аксай',
      '1 Ордж.' => 'Орджоникидзе',
      '2 Ордж.' => 'Орджоникидзе',
      '1 Ордж' => 'Орджоникидзе',
      '2 Ордж' => 'Орджоникидзе',
      'Зооп.' => 'Зоопарк',
      'Военв.' => 'Военвед',
      'Алекс.' => 'Александровка',
      'Ленина' => 'Ленина площадь',
      'Левенц' => 'Ливенцовка',
      'Аксакйский р-н' => 'р-н Аксайский'
    }
    hash_list[district].blank? ? district : hash_list[district]
  end
end