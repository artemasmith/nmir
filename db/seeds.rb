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
    { title: 'Тобольск', location_type: 2 },
    { title: 'Нижняя Тавда', location_type: 2 },
    { title: 'Ялуторовск', location_type: 2 },
    { title: 'Москва', location_type: 2 },
    { title: 'Челябинск', location_type: 2 },
    { title: 'Самара', location_type: 2 },
    { title: 'Волгоград', location_type: 2 },
    { title: 'Чебоксары', location_type: 2 },
    { title: 'Азов', location_type: 2 },
    { title: 'Ростов-на-Дону', location_type: 2 },
    { title: 'Новочеркасск', location_type: 2 },
    { title: 'Батайск', location_type: 2 },
    { title: 'Таганрог', location_type: 2 },
    { title: 'Шахты', location_type: 2 },
    { title: 'Брянск', location_type: 2 },
    { title: 'Коломенск', location_type: 2 },
    { title: 'Жуковски', location_type: 2 },
    { title: 'Клин', location_type: 2 },
    { title: 'Королев', location_type: 2 },
    { title: 'Котельники', location_type: 2 }

].each do |location|
  Location.find_or_create_by(location)
end

tyumen = Location.find_by_title('Тюменская область')
moscow = Location.find_by_title('Московская область')
rostov = Location.find_by_title('Ростовская область')
Location.find_by_title('Тюмень').update(location_id: tyumen.id)
Location.find_by_title('Ялуторовск').update(location_id: tyumen.id)
Location.find_by_title('Нижняя Тавда').update(location_id: tyumen.id)
Location.find_by_title('Тобольск').update(location_id: tyumen.id)
Location.find_by_title('Брянск').update(location_id: moscow.id)
Location.find_by_title('Коломенск').update(location_id: moscow.id)
Location.find_by_title('Жуковски').update(location_id: moscow.id)
Location.find_by_title('Клин').update(location_id: moscow.id)
Location.find_by_title('Королев').update(location_id: moscow.id)
Location.find_by_title('Котельники').update(location_id: moscow.id)
Location.find_by_title('Москва').update(location_id: moscow.id)
Location.find_by_title('Азов').update(location_id: rostov.id)
Location.find_by_title('Ростов-на-Дону').update(location_id: rostov.id)
Location.find_by_title('Новочеркасск').update(location_id: rostov.id)
Location.find_by_title('Батайск').update(location_id: rostov.id)
Location.find_by_title('Таганрог').update(location_id: rostov.id)
Location.find_by_title('Шахты').update(location_id: rostov.id)
mc = Location.find_by_title('Москва')
rc = Location.find_by_title('Ростов-на-Дону')
tc = Location.find_by_title('Тюмень')
mc.sublocations.find_or_create_by(title: 'Арбат', location_type: 1)
mc.sublocations.find_or_create_by(title: 'м Фрунзенская', location_type: 1)
mc.sublocations.find_or_create_by(title: 'Киевский вокзал', location_type: 1)
mc.sublocations.find_or_create_by(title: 'м Баумана', location_type: 1)
mc.sublocations.find_or_create_by(title: 'Север', location_type: 1)
mc.sublocations.find_or_create_by(title: 'Запад', location_type: 1)
mc.sublocations.find_or_create_by(title: 'Восток', location_type: 1)
rc.sublocations.find_or_create_by(title: 'Центр', location_type: 1)
rc.sublocations.find_or_create_by(title: 'ЖД', location_type: 1)
rc.sublocations.find_or_create_by(title: 'ЗЖМ', location_type: 1)
rc.sublocations.find_or_create_by(title: 'Левый берег', location_type: 1)
rc.sublocations.find_or_create_by(title: 'Фрунзе', location_type: 1)
rc.sublocations.find_or_create_by(title: 'Каменка', location_type: 1)
tc.sublocations.find_or_create_by(title: 'Центр', location_type: 1)
tc.sublocations.find_or_create_by(title: 'Заречный', location_type: 1)
tc.sublocations.find_or_create_by(title: 'Восточный', location_type: 1)
tc.sublocations.find_or_create_by(title: 'Восточный 2', location_type: 1)
tc.sublocations.find_or_create_by(title: 'Войновка', location_type: 1)
tc.sublocations.find_or_create_by(title: 'Мыс', location_type: 1)
tc.sublocations.find_or_create_by(title: 'Маяк', location_type: 1)



[
    { offer_type: 1, category: 1, property_type: 1,  name: 'Сдам однушку',
      phone: '891912332122', price_from: 100, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent', city_id: Location.find_by_title('Ялуторовск').id },
    { offer_type: 1, category: 1, property_type: 1, expire_date: Date.today + 1.month,
      name: 'Сдам Двухкомнттную',      phone: '891912332133', price_from: 200,
      region_id: Location.where(location_type: 2).first.id , adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Восточный').id },
    { offer_type: 1, category: 1, property_type: 1, expire_date: Date.today + 1.month, name: 'Сдам хрущевку',
      phone: '891912332162', price_from: 50, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Заречный').id },
    { offer_type: 0, category: 1, property_type: 1, expire_date: Date.today + 1.month,
      name: 'Продам однушку', phone: '8919123312311', price_from: 55000,
      region_id: Location.where(location_type: 2).first.id, adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('ЖД').id },
    { offer_type: 0, category: 1, property_type: 1, expire_date: Date.today + 1.month,
      name: 'Продам квартиру-студию. Евроремонт. Торг.', phone: '8919123314512', price_from: 25000,
      region_id: Location.where(location_type: 2).first.id, adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Восточный').id },
    { offer_type: 0, category: 6, property_type: 0,
      name: 'Продам офис',
      phone: '892912332122', price_from: 9000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Центр').id },
    { offer_type: 0, category: 6, property_type: 0,
      name: 'Продам офисное помещение в районе кривоаанов',
      phone: '892912332122', price_from: 120000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Восточный').id },
    { offer_type: 4, category: 1, property_type: 1,
      name: 'Куплю хату с краю',
      phone: '896912332122', price_from: 1000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Заречный').id },
    { offer_type: 4, category: 2, property_type: 1,
      name: 'Куплю дом',
      phone: '541322', price_from: 100000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('ЖД').id },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму дом или апартаменты',
      phone: '892200120042', price_from: 1000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Восточный').id },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму коттедж',
      phone: '892200122942', price_from: 10000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('ЖД').id },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму коттедж у реки',
      phone: '892200120064', price_from: 25000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Заречный').id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, отапливаемый',
      phone: '892912334451', price_from: 150000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Восточный').id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, с ямой',
      phone: '892912334457', price_from: 200000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Центр').id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в центре, охраняемый',
      phone: '892912334459', price_from: 1500000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      city_id: Location.find_by_title('Тюмень').id, district_id: Location.find_by_title('Центр').id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в центре, неотапиив',
      phone: '892912334459', price_from: 100000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent', city_id: 4, district_id: Location.find_by_title('Восточный').id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в за бугром, охраняемый',
      phone: '892912334459', price_from: 1990000, region_id: Location.where(location_type: 2).first.id,
      adv_type: 0, currency: 1, sales_agent: 'test agent', city_id: 4, district_id: Location.find_by_title('Центр').id }

].each do |advertisement|
  a = Advertisement.find_or_create_by(advertisement)
  puts "created #{a.errors.messages.to_s}"
end

#ADMIN
User.create(name: 'admin', email: 'admin@admin.ru', password: '12345678', role: :admin)

