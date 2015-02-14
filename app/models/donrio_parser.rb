class DonrioParser

  def self.parse_flat title
    title = title.split('/')
    title.each {|s| s.strip! }
    if title.count == 1
      #street and house or street only
      title = title[0].split(',')
      title.each {|s| s.strip! }
      street = title[0]
      if title.count == 2
        #street and house
        address  = title[1]
      end
    elsif title.count == 2
      #street/street or street, house/house
      if title[1].match /^\d+[[:alpha:]]{0,1}$/
        #street, house/house
        street = title[0].split(',')[0].strip
        address = title[0].split(',')[1] + '/' + title[1]
      elsif title[1].match /^\d*\s*[[:alpha:]]+$/
        #street/street or street,house/street
        #if we have 2 streets we save only one?
        temp = title[0].split(',')
        temp.each {|s| s.strip! }
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
    street = street.present? ? Matcher.rename_street(street).mb_chars.upcase.to_s : nil
    address = address.present? ? address.mb_chars.upcase.to_s : nil
    return street, address
  end

  def self.parse_house title
    title = title.split('/')
    title.each {|s| s.strip! }
    district, area, street, street2, address = ''
    if title.count == 3
      #area/street/street | area/street/address (very rarely)
      area = title[0]
      street = title[1]
      title[2].match /^\d+[[:alpha:]]{0,1}$/ ? address = title[2].strip : street2 = title[2].strip
    elsif title.count == 2
      #area/area | area/address | area/street, address
      if title[1].split(',').count == 2
        #area/street, house
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
    return area, street, address
  end

  def self.prepare_char str
    res = str.index /\d{2}\.\d{2}\.\d{4}/
    res = res.present? ? res = str[0..res-1] : str
    res
  end

  def self.parse_comment row, titles, parsed
    comment = %Q(цена: #{row[1]} т.р., этажей: #{row[titles['Эт.']]}, комнат: #{row[titles['ком.']]}, площадь: #{row[titles['Площадь']]}, #{DonrioParser.prepare_char(row[titles['Хар']])})
    if titles.keys.include?('Sуч.Всотках')
      comment += ", площадь-участка: #{row[titles['Sуч.Всотках']]}"
    end
    if !parsed
      comment += ", адрес: #{row[titles['Адрес']]}, район: #{row[titles['Район']]},"
    end
    comment
  end

  def self.parse_phone row, titles
    phone = row[titles['Тел контанк']].gsub(/[^[:word:]]/, '').gsub /[[:alpha:]]/, ''
  end

  def self.parse_name row, titles
    name = row[titles['Тел контанк']].gsub(/[^[:word:]]/, '').gsub /[^[:alpha:]]/, ''
  end

  def self.parse_space_from row, titles
    space_from = row[titles['Площадь']].to_i
    space_from
  end

  def self.parse_outdoors_space_from row, titles
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
    return nil if row[titles['Эт.']].blank?
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
    row[titles['ком.']].to_i
  end

  def self.parse_offer_type row
    :sale
  end

  def self.parse_adv_type row
    :offer
  end

  def self.parse_property_type row
    :commerce
  end

  def self.parse_category row, titles
    category = ''
    har = row[titles['Хар']]
    if har.match /дом/i
      category = :house
    elsif har.match /участ[оки]/i
      category = :land
    else
      category = :flat
    end
    category
  end

end