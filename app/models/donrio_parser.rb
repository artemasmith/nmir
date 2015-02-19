class DonrioParser


  def self.prepare_char str
    res = str.index /\d{2}\.\d{2}\.\d{4}/
    res = res.present? ? res = str[0..res-1] : str
    res
  end

  def self.parse_comment row, titles
    list = []
    list << "цена: #{row[1]} т.р." if row[1].present?
    list << "этажей: #{row[titles['Эт.']]}" if row[titles['Эт.']].present?
    list << "комнат: #{row[titles['ком.']]}" if row[titles['ком.']].present?
    list << "площадь: #{row[titles['Площадь']]}" if row[titles['Площадь']].present?
    if titles.keys.include?('Sуч.Всотках')
      list << "площадь-участка: #{row[titles['Sуч.Всотках']]}" if row[titles['Sуч.Всотках']].present?
    end
    list.join(', ')
  end

  def self.parse_landmark row, titles, parsed
    "адрес: #{row[titles['Адрес']]}, район: #{row[titles['Район']]}" unless parsed
  end

  def self.parse_name_and_phone row, titles
    begin
      prepare = row[titles['Тел контанк']].gsub(/агент на % не претендует/i, '').gsub(/посредник % на не претендует/i, '').gsub(/у нас как агент/i, '').strip.scan(/[A-Za-z_А-Яа-я]+|[\s0-9\(\)-]+/)
      list = prepare.map do |e|
         e.gsub(/[-+\(\)\s]/, '').strip
      end.delete_if do |e|
        e == ''
      end.group_by do|e|
        e !~/^\d+$/
      end.tap do |t|
          t[true] = (t[true] || [])
                       .join(' ')
                       .strip
      end.tap do |t|
        (t[false] || []).map! do |e|
          (e.first =~ /\d/) && (e.length == 7) ? "+7863#{e}" : e
        end.map! do |e|
          (e.first =~ /\d/) && (e.length == 10) ? "+7#{e}" : e
        end
      end
      return list[true], list[false].first
    rescue
      return nil, nil
    end
  end

  def self.parse_space_from row, titles
    space_from = row[titles['Площадь']].to_i
    space_from
  end

  def self.parse_outdoors_space_from row, titles
    return nil if titles['Sуч.Всотках'].blank?
    text = row[titles['Sуч.Всотках']].to_s
    temp = text.split(',')
    if text.include?('га')
      outdoors_space_from = temp[0].to_f * 100
      outdoors_space_from += temp[1].to_f * 10 if temp.count == 2
      return outdoors_space_from
    else
      temp = row[titles['Sуч.Всотках']].to_s.split(',')
      outdoors_space_from = temp[0].to_f
      outdoors_space_from += temp[1].to_f * 0.1 if temp.count == 2
      return outdoors_space_from
    end
  end

  def self.parse_price row
    row[1].to_i * 1000
  end

  def self.parse_floor_from row, titles
    return nil if row[titles['Эт.']].blank? || titles['Sуч.Всотках'].present?
    if titles['Sуч.Всотках'].present?
      floor_from = row[titles['Эт.']].match(/\d+,*\d*/).to_s.to_i
      return nil if floor_from == 0
    else
      temp = row[titles['Эт.']].split('/')
      floor_from = temp[0].to_i
    end
    floor_from
  end

  def self.parse_floor_cnt_from row, titles
    return nil if row[titles['Эт.']].blank?
    temp = row[titles['Эт.']].split('/')
    floor_cnt_from = temp.count == 2 ? temp[1].to_i : nil
    floor_cnt_from
  end

  def self.parse_room row, titles
    if titles['Sуч.Всотках'].present?
      nil
    else
      row[titles['ком.']].to_i
    end
  end

  def self.parse_offer_type row
    :sale
  end

  def self.parse_category row, titles
    category = if titles['Sуч.Всотках'].present?
      case
        when row[titles['Площадь']].to_s.match(/участок/i) then :ijs
        else :house
      end
    else
      case
        when row[titles['ком.']].to_s.match(/к/i) then :room
        when row[titles['ком.']].to_s.match(/г/i) then :hotel
        else :flat
      end
    end
    return category
  end

end