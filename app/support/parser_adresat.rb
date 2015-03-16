class ParserAdresat

  def self.parse_category row
     case
       when row[0].mb_chars.downcase.to_s.match(/квартир/i) then :flat
       when row[0].mb_chars.downcase.to_s.match(/комна/i) then :room
       when row[0].mb_chars.downcase.to_s.match(/овостр/i) then :newbuild
       when row[0].mb_chars.downcase.to_s.match(/дом/i) then :house
       when row[0].mb_chars.downcase.to_s.match(/участ/i) then :ijs
       when row[0].mb_chars.downcase.to_s.match(/гостинка/i) then :hotel
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


  def self.field_valid? field, row, titles
    titles[field].present? && row[titles[field]].present? && !row[titles[field]].to_s.match('\?') && !row[titles[field]].to_s.strip.match(/^0$/)
  end

  def self.parse_comment row, titles
    comment = []
    obj = self.parse_category row
    obj = case obj
            when :flat then "квартиру"
            when :ijs then "участок"
            when :house then "дом"
            when :room then 'комнату'
            when :newbuild then 'квартиру в новостройке'
            when :hotel then 'гостиницу'
            else 'квартиру'
          end

    d,s,a = self.parse_street_address row, titles
    landmark = self.parse_landmark row,titles, nil
    full_address = "#{d} #{landmark} #{s} #{a}."

    uc = row[titles[:comment]].split('|')[2]
    uc = ParserUtil.rename :comment, uc

    comment << "Продаю #{obj},"
    if obj.match("квартир") || obj.match('комнат') || obj.match('гостиницу')
      comment << "#{self.parse_room_from(row, titles)}к" if field_valid? 'ком', row, titles
      comment << "#{self.parse_floor_from(row, titles)}/#{self.parse_floor_cnt_from(row, titles)}" if field_valid?('э-н', row, titles) &&
          field_valid?('эт', row, titles)
      comment << "#{self.parse_walls(row, titles)}," if field_valid?('стены', row, titles)

      space = ""
      space = "#{self.parse_space_from(row, titles)}" if field_valid?('Sоб', row, titles)
      space += "/#{self.parse_spl(row, titles)}" if field_valid?('Sж', row, titles)
      space += "/#{self.parse_spk(row, titles)}" if field_valid?('Sк', row, titles)

      comment << space if space.present?

      comment << "санузел #{self.parse_bath(row, titles)}," if field_valid?('су', row, titles)
      comment << "балкон #{self.parse_balcony(row, titles)}," if field_valid?('бал', row, titles)
      comment << "окна #{self.parse_windows(row, titles)}," if field_valid?('окна', row, titles)
      comment << "комнаты #{self.parse_blueprint(row, titles)}," if field_valid?('план.1', row, titles)
      comment << "состояние #{self.parse_char(row, titles)}," if field_valid?('отд.хар', row, titles)
      comment << "дом построен в #{self.parse_year(row, titles)} г.," if field_valid?('год', row, titles)
      comment <<  uc + ',' if uc != '0' && uc.present?
      comment << full_address
    elsif obj == "участок"
      comment << "#{self.parse_outdoors_space_from(row, titles)} сот." if field_valid?('Sуч', row, titles)
      comment << full_address
      comment << "Дорога к участку #{self.parse_road(row, titles)}," if field_valid?('дорога к', row, titles)
      comment << "въезд для #{self.parse_parking(row, titles)}." if field_valid?('въезд', row, titles)
      comment << "#{self.parse_gas(row, titles)}," if field_valid?('газ', row, titles)
      comment << "#{self.parse_power(row, titles)}," if field_valid?('элек', row, titles)
      comment << "#{self.parse_water(row, titles)}," if field_valid?('вода', row, titles)
      comment << "канализация #{self.parse_plumbing(row, titles)}," if field_valid?('кан', row, titles)
      comment <<  uc if uc != '0' && uc.present?

    else
      comment << "#{self.parse_space_from(row, titles)}" if field_valid?('Sоб', row, titles)
      comment << "#{self.parse_walls(row, titles)}," if field_valid?('стены', row, titles)
      comment << "участок #{self.parse_outdoors_space_from(row, titles)}." if field_valid?('Sуч', row, titles)
      comment << "Удобства #{self.parse_facilities(row, titles)}," if field_valid?('уд', row, titles)
      comment << "состояние #{self.parse_renovation(row, titles)}," if field_valid?('отд.кач', row, titles)
      comment << uc if uc != '0' && uc.present?
      comment << "фасад #{self.parse_front(row, titles)}," if field_valid?('фасад', row, titles)
      comment << "двор #{self.parse_front_standalone(row, titles)}," if field_valid?('обособл', row, titles)
      comment << "въезд для #{self.parse_parking(row, titles)}." if field_valid?('въезд', row, titles)
    end
    comment.join(' ')
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

      front_standalone: {name: 'двор.обос', type: 'to_s' },
      facilities: {name: 'уд', type: 'to_s' },
      spl: {name: 'Sж', type: 'to_d' },
      spk: {name: 'Sк', type: 'to_d' },
      power: {name: 'элек', type: 'to_s' },
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