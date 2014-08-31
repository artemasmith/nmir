# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
[
    { title: 'Тюменская область', location_type: 0 },
    { title: 'Ростовская область', location_type: 0 },
    { title: 'Московская область', location_type: 0 },
    { title: 'Тюмень', location_type: 2 },
    { title: 'Ростов-на-Дону', location_type: 2 },
    { title: 'Тобольск', location_type: 2 },
    { title: 'Нижняя Тавда', location_type: 2 },
    { title: 'Ялуторовск', location_type: 2 },
    { title: 'Москва', location_type: 2 },
    { title: 'Челябинск', location_type: 2 },
    { title: 'Самара', location_type: 2 },
    { title: 'Волгоград', location_type: 2 },
    { title: 'Чебоксары', location_type: 2 }

].each do |location|
  Location.find_or_create_by(location)
end

#ADVERTISEMENTS
[
    { offer_type: 1, category: 1, property_type: 1,  name: 'Сдам однушку',
      phone: '891912332122', price_from: 100, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 1, category: 1, property_type: 1,
      name: 'Сдам Двухкомнттную',      phone: '891912332133', price_from: 200,
      region_id: Location.where(location_type: 2).first.id , adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 1, category: 1, property_type: 1, name: 'Сдам хрущевку',
      phone: '891912332162', price_from: 50, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent'  },
    { offer_type: 0, category: 1, property_type: 1,
      name: 'Продам однушку', phone: '8919123312311', price_from: 55000,
      region_id: Location.where(location_type: 2).first.id, adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 0, category: 1, property_type: 1,
      name: 'Продам квартиру-студию. Евроремонт. Торг.', phone: '8919123314512', price_from: 25000,
      region_id: Location.where(location_type: 2).first.id, adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 0, category: 6, property_type: 0,
      name: 'Продам офис',
      phone: '892912332122', price_from: 9000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 0, category: 6, property_type: 0,
      name: 'Продам офисное помещение в районе кривоаанов',
      phone: '892912332122', price_from: 120000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 4, category: 1, property_type: 1,
      name: 'Куплю хату с краю',
      phone: '896912332122', price_from: 1000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 4, category: 2, property_type: 1,
      name: 'Куплю дом',
      phone: '541322', price_from: 100000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму дом или апартаменты',
      phone: '892200120042', price_from: 1000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму коттедж',
      phone: '892200122942', price_from: 10000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму коттедж у реки',
      phone: '892200120064', price_from: 25000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, отапливаемый',
      phone: '892912334451', price_from: 150000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, с ямой',
      phone: '892912334457', price_from: 200000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в центре, охраняемый',
      phone: '892912334459', price_from: 1500000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent' },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в центре, неотапиив',
      phone: '892912334459', price_from: 100000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent', city_id: 4 },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в за бугром, охраняемый',
      phone: '892912334459', price_from: 1990000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent', city_id: 4 }

].each do |advertisement|
  a = Advertisement.find_or_create_by(advertisement)
  puts "created #{a.errors.messages.to_s}"
end

#ADMIN
User.create(name: 'admin', email: 'admin@admin.ru', password: '12345678', role: :admin)

tyumen = Location.find_by_title('Тюменская область')
Location.find_by_title('Тюмень').update(location_id: tyumen.id)
Location.find_by_title('Ялуторовск').update(location_id: tyumen.id)
Location.find_by_title('Нижняя Тавда').update(location_id: tyumen.id)
Location.find_by_title('Тобольск').update(location_id: tyumen.id)