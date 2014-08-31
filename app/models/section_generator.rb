module SectionGenerator
  def self.by_offer_category(offer_type, category, location, loc_chain_url)
    url = "#{loc_chain_url}/#{chain_url([offer_type, category])}"
    STDERR.puts url
    Section.create_with(
      url: url
    )
    .find_or_create_by(
      offer_type: Section.offer_types[offer_type], 
      category: Section.categories[category], 
      location_id: location.id
    ).increment!(:advertisements_count)
  end

  def self.by_property_offer(property_type, offer_type, location, loc_chain_url)
    url = "#{loc_chain_url}/#{chain_url([offer_type, property_type])}"

    STDERR.puts url
    Section.create_with(
      url: url
    )
    .find_or_create_by(
      property_type: Section.property_types[property_type], 
      offer_type: Section.offer_types[offer_type], 
      location_id: location.id
    ).increment!(:advertisements_count)
  end

  def self.by_location(location, loc_chain_url)
    STDERR.puts loc_chain_url


    Section.create_with(
      url: loc_chain_url
    )
    .find_or_create_by(location_id: location.id, offer_type: nil, property_type: nil, category: nil ).increment!(:advertisements_count)
  end

  def self.chain_url(locations)
    url = []
    locations.each do |loc|
      url << loc.parameterize
    end

    if url.empty?
      url << '/' 
    else
      url.join('/')
    end
  end

  # returns translated enum value 
  def self.enum_title(type)
    I18n.t("activerecord.attributes.section.enum_title.#{type}")
  end
  
  # returns translated & translited enum value
  def self.enum_url(type)
    Russian::translit Section.enum_title(type)
  end
end
