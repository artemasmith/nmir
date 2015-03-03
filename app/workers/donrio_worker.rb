class DonrioWorker
  class << self
    def find_child parent, title, type = :all
      parent.children_locations(type).where('title ilike ?', "%#{title}%").first
    end

    def find_address_locations_in_db parent, path, result
      return result, false if path.blank?

      correct_path_first = ParserUtil.rename(path.first)
      return nil, false unless correct_path_first.is_a?(String)
      sub_location = find_child parent, correct_path_first
      return nil, false if sub_location.blank?
      result << sub_location


      correct_path_second = ParserUtil.rename(path.second)
      return sub_location, false unless correct_path_second.is_a?(String)

      if sub_location.street? && path.second.present? && correct_path_second.to_i > 0
        sub_sub_location = sub_location.children_locations.where(title: correct_path_second.to_i.to_s).first ||
            create_address(parent: sub_location, title: correct_path_second.to_i.to_s)
        result << sub_sub_location
        return nil, true
      end

      return sub_location, false
    end

    def find_locations_in_db parent_name, original_district, original_address, result = []

      district_name = ParserUtil.rename(original_district)
      address_name = ParserUtil.rename(original_address)

      if district_name.is_a?(String) || district_name.is_a?(NilClass)
        superparent = Location.where(title: parent_name).first

        return result, [original_district, original_address].delete_if{|e| e.blank?}.join(', ') if district_name.blank?
        if superparent.city?
          district = find_child(superparent, district_name, :admin_area) ||
              find_child(superparent, district_name, :non_admin_area)
        else
          district = find_child(superparent, district_name)
        end

        return result, [original_district, original_address].delete_if{|e| e.blank?}.join(', ') if district.blank?

        result << superparent
        result << district
      else
        result = district_name
        district = result.last
      end

      if address_name.is_a?(String) || address_name.is_a?(NilClass)

        return result, original_address if address_name.blank?

        address_name_list = address_name.split('/').delete_if{ |e| e.blank? }
        path_list = address_name_list.first.split(',').map{ |e| e.to_s.strip }.delete_if{ |e| e.blank? } if address_name_list.first.present?
        addition_path_list = address_name_list.second.split(',').map{ |e| e.to_s.strip }.delete_if{ |e| e.blank? } if address_name_list.second.present?

        address, parsed = find_address_locations_in_db district, path_list, result
        if address.blank?
          return result, parsed ? nil : original_address
        end

        address, parsed = find_address_locations_in_db address, addition_path_list, result
        if address.blank?
          return result, parsed ? nil : original_address.split('/').delete_if{ |e| e.blank? }.second
        end
      else
        result << address_name
      end

      return result, nil
    end

    def get_location loc_params
      district = loc_params[:dist]
      address = loc_params[:addr]


      ro = Location.where(title: 'обл Ростовская').first
      result, unparsed = find_locations_in_db('г Ростов-на-Дону', district, address, [ro])
      result, unparsed =  find_locations_in_db('обл Ростовская', district, address) if result == [ro]

      return (result.presence || [ro]), unparsed
    end


    def create_address attr
      parent = attr[:parent]
      address = parent.sublocations.create(title: attr[:title], location_type: :address)
      parent.loaded_resource!
      address
    end

    def perform row, titles
      name, phone = ParserDonrio.parse_name_and_phone row, titles

      adv = Advertisement.new
      contact = User.get_contact(phone: phone, name: name.presence || '(имя не указано)', source: User::USER_SOURCES.index(:donrio))

      if contact
        adv.user = contact
      else
        return
      end

      adv.offer_type = ParserDonrio.parse_offer_type row
      adv.category = ParserDonrio.parse_category row, titles

      floor_from = ParserDonrio.parse_floor_from row, titles
      adv.floor_from = floor_from if floor_from.present? && floor_from > 0
      floor_cnt_from = ParserDonrio.parse_floor_cnt_from row, titles
      adv.floor_cnt_from = floor_cnt_from if floor_cnt_from.present? && floor_cnt_from > 0


      room_from = ParserDonrio.parse_room row, titles
      adv.room_from = room_from if room_from.present? && room_from > 0

      space_from = ParserDonrio.parse_space_from row, titles
      adv.space_from = space_from if space_from.present? && space_from > 0


      outdoors_space_from = ParserDonrio.parse_outdoors_space_from row, titles
      adv.outdoors_space_from = outdoors_space_from if outdoors_space_from.present? && outdoors_space_from > 0

      adv.price_from = ParserDonrio.parse_price row



      location = { dist: row[titles['Район']], addr: row[titles['Адрес']]}
      locations, unparsed = get_location(location)

      adv.comment = ParserDonrio.parse_comment row, titles

      adv.landmark = ParserDonrio.parse_landmark unparsed

      adv_params = { locations: locations, offer_type: adv.offer_type, category: adv.category, property_type: adv.property_type,
                     user_id: adv.user_id, price: adv.price_from }

      cadv = Advertisement.check_existence adv_params
      adv.locations = locations

      adv.get_remote_coords unless cadv

      adv.save unless cadv
    end
  end
end