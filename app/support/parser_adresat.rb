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

  def self.parse_contact row
    row.split('|').each do |str|

    end
  end



end