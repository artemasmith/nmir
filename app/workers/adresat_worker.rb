class AdresatWorker

  def perform row, titles
    name, phone = ParserAdresat.parse_name_and_phone row

    adv = Advertisement.new
    contact = User.get_contact(phone: phone, name: name.presence || '(имя не указано)', source: User::USER_SOURCES.index(:adresat))

    if contact
      adv.user = contact
    else
      return
    end

    adv.offer_type = ParserAdresat.parse_offer_type row
    adv.category = ParserAdresat.parse_category row

    floor_from = ParserAdresat.parse_floor_from row, titles
    adv.floor_from = floor_from if floor_from.present? && floor_from > 0
    floor_cnt_from = ParserAdresat.parse_floor_cnt_from row, titles
    adv.floor_cnt_from = floor_cnt_from if floor_cnt_from.present? && floor_cnt_from > 0


    room_from = ParserAdresat.parse_room row, titles
    adv.room_from = room_from if room_from.present? && room_from > 0

    space_from = ParserAdresat.parse_space_from row, titles
    adv.space_from = space_from if space_from.present? && space_from > 0


    outdoors_space_from = ParserAdresat.parse_outdoors_space_from row, titles
    adv.outdoors_space_from = outdoors_space_from if outdoors_space_from.present? && outdoors_space_from > 0

    adv.price_from = ParserAdresat.parse_price row



    location = { dist: row[titles['Район']], addr: row[titles['Адрес']]}
    locations, unparsed = get_location(location)

    adv.comment = ParserAdresat.parse_comment row, titles

    adv.landmark = ParserAdresat.parse_landmark unparsed

    adv_params = { locations: locations, offer_type: adv.offer_type, category: adv.category, property_type: adv.property_type,
                   user_id: adv.user_id, price: adv.price_from }

    cadv = Advertisement.check_existence adv_params
    adv.locations = locations

    adv.get_remote_coords unless cadv


  end
end