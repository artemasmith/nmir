class ParserAdresat

  def self.parse_category row
     case
       when row.mb_chars.downcase.to_s.match(/квартир/) then :flat
       when row.mb_chars.downcase.to_s.match(/дом/) then :house
       when row.mb_chars.downcase.to_s.match(/участ[ки|ок]{0,1}/) then :ijs
       else nil
     end
  end

  def self.parse_offer_type row
    case
      when row.mb_chars.downcase.to_s.match(/прода/) then :sale
      else nil
    end
  end

  def self.parse_adv_type row
    case
      when row.mb_chars.downcase.to_s.match(/прода/) then :offer
      when row.mb_chars.downcase.to_s.match(/покуп/) then :buy
      else nil
    end
  end

  def self.parse_property_type row
    :residental
  end


  def self.parse_name_and_phone row
    begin
      unparsed_contact = row[1].split('|')[1].gsub(/[-+\(\)\,\s]/, '').strip.split('-')
      phone = unparsed_contact[1] if unparsed_contact[1].match(/\d/)
      name = unparsed_contact[0] if unparsed_contact[0].match(/[A-Za-z_А-Яа-я]/)
      return name, phone
    rescue
      return nil, nil
    end
  end


  VALUES = {
      floor_from: { name: 'эт', type: 'to_i' },
      space_from: { name: 'Sоб', type: 'to_d' },
      space_outdoor_from: { name: 'Sуч', type: 'to_d' },
      address: { name: 'отд.хар', type: 'to_s' },
      floor_cnt_from: { name: 'э-н', type: 'to_i' },
      room_from: { name: 'ком', type: 'to_i' },

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
      decor: { name: '', type: 'to_s' },
      blueprint: { name: 'план.1', type: 'to_s' },
      remont: { name: 'отд.кач', type: 'to_s' },
      parking: { name: 'въезд', type: 'to_s' },
      gazon: { name: 'двор.обос', type: 'to_s' },
      front: { name: 'фасад', type: 'to_s' },

  }

  def self.method_missing(name, *args)
    begin
      name = name.to_s.gsub('parse_', '')
      return nil if VALUES[name.to_sym].blank?

      field = VALUES[name.to_sym][:name]
      type = VALUES[name.to_sym][:type]

      return nil if args.blank? || args[0][field].blank? || args[0][field].send(type) == 0

      result = args[0][field].strip.send(type)
      result = ParserUtil.rename name.to_sym, result if VALUES[name.to_sym][:type] == 'to_s'
      result

    rescue ScriptError => e
      #raise "Wow! Do not say so! #{e}"
      return nil
    end
  end




end