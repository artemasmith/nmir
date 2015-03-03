module SectionGenerator
  def self.by_offer_category(offer_type, category, location, loc_chain_url, loc_chain_title, short_loc_title)
    url = "/#{loc_chain_url}/#{chain_url([offer_type, category])}"
    Section.create_with(
        generate_attributes(url, offer_type, category, nil, loc_chain_title, short_loc_title)
    )
    .find_or_create_by(
      offer_type: Section.offer_types[offer_type], 
      category: Section.categories[category], 
      location_id: location.id
    ).increment!(:advertisements_count)
  end


  def self.by_property_offer(property_type, offer_type, location, loc_chain_url, loc_chain_title, short_loc_title)
    url = "/#{loc_chain_url}/#{chain_url([offer_type, property_type])}"
    Section.create_with(
        generate_attributes(url, offer_type, nil, property_type, loc_chain_title, short_loc_title)
    )
    .find_or_create_by(
      property_type: Section.property_types[property_type], 
      offer_type: Section.offer_types[offer_type], 
      location_id: location.id
    ).increment!(:advertisements_count)
  end

  def self.by_location(location, loc_chain_url, loc_chain_title, short_loc_title)
    url = "/#{loc_chain_url}"
    Section.create_with(
        generate_attributes(url, nil, nil, nil, loc_chain_title, short_loc_title)
    )
    .find_or_create_by(location_id: location.id, offer_type: nil, property_type: nil, category: nil ).increment!(:advertisements_count)
  end

  def self.empty
    Section.create_with(
        url: '/'
    )
    .find_or_create_by(location_id:  nil, offer_type: nil, property_type: nil, category: nil ).increment!(:advertisements_count)
  end

  def self.chain_url(params)
    url = []
    params.each do |param|
      url << param.parameterize
    end

    if url.empty?
      url << '/' 
    else
      url.join('/')
    end
  end

  def self.generate_attributes(url, offer_type, category, property_type, loc_chain_title, short_loc_title)
    {
        url: url,
        description: generate_description(offer_type, category, property_type, loc_chain_title),
        keywords: generate_keywords(offer_type, category, property_type, loc_chain_title),
        title: generate_title(offer_type, category, property_type, loc_chain_title),
        short_title: short_loc_title,
        p: nil,
        p2: nil,
        h1: generate_title(offer_type, category, property_type, loc_chain_title),
        h2: nil,
        h3: nil
    }
  end

  def self.generate_title(offer_type, category, property_type, loc_chain_title)
    if(offer_type && category)
      return ["#{enum_title(offer_type)} #{enum_title(category)}", loc_chain_title].compact.join(' ')
    elsif(offer_type && property_type)
      return ["#{enum_title(offer_type)} #{enum_title(property_type)}", loc_chain_title].compact.join(' ')
    elsif(offer_type.blank? && property_type.blank? && category.blank?)
      return ['Недвижимость', loc_chain_title].compact.join(' ')
    end
  end


  def self.generate_keywords(offer_type, category, property_type, loc_chain_title)
    if(offer_type && category)
      return ["#{enum_title(offer_type)} #{enum_title(category)}", loc_chain_title].compact.join(', ')
    elsif(offer_type && property_type)
      return ["#{enum_title(offer_type)} #{enum_title(property_type)}", loc_chain_title].compact.join(', ')
    elsif(offer_type.blank? && property_type.blank? && category.blank?)
      return ['недвижимость', loc_chain_title].compact.join(', ')
    end
  end

  def self.generate_description(offer_type, category, property_type, loc_chain_title)
    if(offer_type && category)
      return [loc_chain_title, enum_title(offer_type), enum_title(category)].compact.join(' ')
    elsif(offer_type && property_type)
      return [loc_chain_title, enum_title(offer_type), enum_title(property_type)].compact.join(' ')
    elsif(offer_type.blank? && property_type.blank? && category.blank?)
      return [loc_chain_title, 'недвижимость'].compact.join(' ')
    end
  end

  # returns translated enum value 
  def self.enum_title(type)
    I18n.t("activerecord.attributes.section.enum_title.#{type}")
  end
  
  # returns translated & translited enum value
  def self.enum_url(type)
    Russian::translit enum_title(type)
  end
end
