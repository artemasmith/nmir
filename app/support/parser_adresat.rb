class ParserAdresat

  def self.parse_category row
     case
       when row.keys[0].mb_chars.downcase.to_s.match(/квартир/) then :flat
       when row.keys[0].mb_chars.downcase.to_s.match(/дом/) then :house
       when row.keys[0].mb_chars.downcase.to_s.match(/участ[ки|ок]{0,1}/) then :ijs
       else nil
     end
  end

  def self.parse_offer_type row
    case
      when row.keys[0].mb_chars.downcase.to_s.match(/прода/) then :sale
      else nil
    end
  end

  def self.parse_adv_type row
    case
      when row.keys[0].mb_chars.downcase.to_s.match(/прода/) then :offer
      when row.keys[0].mb_chars.downcase.to_s.match(/покуп/) then :buy
      else nil
    end
  end

  def self.parse_property_type row
    :residental
  end


  def self.parse_name_and_phone row, titles
    begin
      unparsed_contact = row[titles[:comment]].to_s.split('|')[1].strip.split('-')
      phone = unparsed_contact[1].split(',').first.to_s.strip.gsub(/[-+\(\)\,\s]/, '') if unparsed_contact[1].match(/\d/)
      name = unparsed_contact[0].split(',').first.to_s.strip.gsub(/[-+\(\)\,]/, '') if unparsed_contact[0].match(/[A-Za-z_А-Яа-я]/)
      return name, phone
    rescue
       return nil, nil
    end
  end

  def self.parse_price row, titles
    row[titles['цена']].to_i * 1000
  end

  def self.parse_landmark row, titles, unparsed
    list = []
    list << unparsed if unparsed.present?
    list << row[titles['ориентир']] if row[titles['ориентир']].present? && row[titles['ориентир']].to_s.strip != '?'
    list.join(', ')
  end

  def self.parse_comment row, titles
    comment = []
    comment << "этажей:  #{self.parse_floor_cnt_from(row, titles)}" if titles['э-н'].present? && row[titles['э-н']].present?
    comment << "комнат: #{self.parse_room_from(row, titles)}" if titles['ком'].present? && row[titles['ком']].present?
    comment << "цена:  #{self.parse_price(row, titles)}" if titles['цена'].present? && row[titles['цена']].present?
    comment << "площадь: #{self.parse_space_from(row, titles)}" if titles['Sоб'].present? && row[titles['Sоб']].present?
    comment << "площадь-участка: #{self.parse_outdoors_space_from(row, titles)}" if titles['Sуч'].present? && row[titles['Sуч']].present?
    comment << "отделка: #{self.parse_char(row, titles)}" if titles['отд.хар'].present? && row[titles['отд.хар']].present?
    comment << "год: #{self.parse_year(row, titles)}" if titles['год'].present? && row[titles['год']].present?
    comment << "балкон: #{self.parse_balcony(row, titles)}" if titles['бал'].present? && row[titles['бал']].present?
    comment << "окна: #{self.parse_windows(row, titles)}" if titles['окна'].present? && row[titles['окна']].present?
    comment << "стены: #{self.parse_walls(row, titles)}" if titles['стены'].present? && row[titles['стены']].present?
    comment << "вода: #{self.parse_water(row, titles)}" if titles['вода'].present? && row[titles['вода']].present?
    comment << "сан. узел: #{self.parse_bath(row, titles)}" if titles['су'].present? && row[titles['су']].present?
    comment << "канализация: #{self.parse_plumbing(row, titles)}" if titles['кан'].present? && row[titles['кан']].present?
    comment << "газ: #{self.parse_gas(row, titles)}" if titles['газ'].present? && row[titles['газ']].present?
    comment << "доказательство собственности: #{self.parse_land_status(row, titles)}" if titles['зем.под'].present? && row[titles['зем.под']].present?
    comment << "отделка качество: #{self.parse_renovation(row, titles)}" if titles['отд.кач'].present? && row[titles['отд.кач']].present?
    comment << "планировка: #{self.parse_blueprint(row, titles)}" if titles['план.1'].present? && row[titles['план.1']].present?
    comment << "въезд: #{self.parse_parking(row, titles)}" if titles['въезд'].present? && row[titles['въезд']].present?
    comment << "фасад: #{self.parse_front(row, titles)}" if titles['фасад'].present? && row[titles['фасад']].present?
    comment << "обособленный: #{self.parse_standalone(row, titles)}" if titles['обособл'].present? && row[titles['обособл']].present?
    uc = row[titles[:comment]].split('|')[2]
    uc = ParserUtil.rename :comment, uc
    comment << "комментарий: " + uc if uc != '0' && uc.present?
    comment.join('; ')
  end


  def self.parse_street_address row, titles
    district = row[titles['район']].to_s.strip
    district = '' if district == '?'

    address = row[titles[:comment]].split('|')[0]
    street, address = address.split(',').map{|e| e.strip}.delete_if{|e| e == '?'}
    return district, street, address
  end


  VALUES = {
      floor_from: { name: 'эт', type: 'to_i' },
      space_from: { name: 'Sоб', type: 'to_d' },
      outdoors_space_from: { name: 'Sуч', type: 'to_d' },
      #address: { name: 'отд.хар', type: 'to_s' },
      floor_cnt_from: { name: 'э-н', type: 'to_i' },
      room_from: { name: 'ком', type: 'to_i' },
      price: { name: 'цена', type: 'to_d' },
      landmark: { name: 'ориентир', type: 'to_s' },

      year: { name: 'год', type: 'to_s' },
      balcony: { name: 'бал', type: 'to_s' },
      windows: { name: 'окна', type: 'to_s' },
      char: { name: 'отд.хар', type: 'to_s' },
      walls: { name: 'стены', type: 'to_s' },
      water: { name: 'вода', type: 'to_s' },
      bath: { name: 'су', type: 'to_s' },
      plumbing: { name: 'кан', type: 'to_s' },
      gas: { name: 'газ', type: 'to_s' },
      land_status: { name: 'зем.под', type: 'to_s' },
      blueprint: { name: 'план.1', type: 'to_s' },
      renovation: { name: 'отд.кач', type: 'to_s' },
      parking: { name: 'въезд', type: 'to_s' },
      gazon: { name: 'двор.обос', type: 'to_s' },
      front: { name: 'фасад', type: 'to_s' },
      standalone: { name: 'обособл', type: 'to_s' },
      road: { name: 'дорога к', type: 'to_s' },

  }





  def self.method_missing(name, *args)
    begin
      name = name.to_s.gsub('parse_', '')

      field = VALUES[name.to_sym][:name]
      type = VALUES[name.to_sym][:type]

      result = args[0][args[1][field]].to_s.strip.send(type)
      result = ParserUtil.rename name.to_sym, result if VALUES[name.to_sym][:type] == 'to_s'
      result = nil if result == '?'
      result
    rescue
      return nil
    end
  end




end