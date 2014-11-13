# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
[
    { title: 'Тюменская область', location_type: 'region' },
    { title: 'Ростовская область', location_type: 'region' },
    { title: 'Московская область', location_type: 'region' },
    { title: 'Tyumen rayon', location_type: 'district' },
    { title: 'Moscow rayon', location_type: 'district' },
    { title: 'Rostov rayon', location_type: 'district' },
    { title: 'Тюмень', location_type: 'city' },
    { title: 'Тобольск', location_type: 'city' },
    { title: 'Нижняя Тавда', location_type: 'city' },
    { title: 'Ялуторовск', location_type: 'city' },
    { title: 'Москва', location_type: 'city' },
    { title: 'Челябинск', location_type: 'city' },
    { title: 'Самара', location_type: 'city' },
    { title: 'Волгоград', location_type: 'city' },
    { title: 'Чебоксары', location_type: 'city' },
    { title: 'Азов', location_type: 'city' },
    { title: 'Ростов-на-Дону', location_type: 'city' },
    { title: 'Новочеркасск', location_type: 'city' },
    { title: 'Батайск', location_type: 'city' },
    { title: 'Таганрог', location_type: 'city' },
    { title: 'Шахты', location_type: 'city' },
    { title: 'Брянск', location_type: 'city' },
    { title: 'Коломенск', location_type: 'city' },
    { title: 'Жуковски', location_type: 'city' },
    { title: 'Клин', location_type: 'city' },
    { title: 'Королев', location_type: 'city' },
    { title: 'Котельники', location_type: 'city' }

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
mc.sublocations.find_or_create_by(title: 'Арбат', location_type: 'admin_area')
mc.sublocations.find_or_create_by(title: 'м Фрунзенская', location_type: 'admin_area')
mc.sublocations.find_or_create_by(title: 'Киевский вокзал', location_type: 'admin_area')
mc.sublocations.find_or_create_by(title: 'м Баумана', location_type: 'admin_area')
mc.sublocations.find_or_create_by(title: 'Север', location_type: 'admin_area')
mc.sublocations.find_or_create_by(title: 'Запад', location_type: 'admin_area')
mc.sublocations.find_or_create_by(title: 'Восток', location_type: 'admin_area')
rc.sublocations.find_or_create_by(title: 'Центр', location_type: 'admin_area')
rc.sublocations.find_or_create_by(title: 'ЖД', location_type: 'admin_area')
rc.sublocations.find_or_create_by(title: 'ЗЖМ', location_type: 'admin_area')
rc.sublocations.find_or_create_by(title: 'Левый берег', location_type: 'admin_area')
rc.sublocations.find_or_create_by(title: 'Фрунзе', location_type: 'admin_area')
admin_area = rc.sublocations.find_or_create_by(title: 'Октябрьский', location_type: 3 )
non_admin_area = rc.sublocations.find_or_create_by(title: 'Западный', location_type: 4 )
street = rc.sublocations.find_or_create_by(title: 'Ворошиловский', location_type: 5 )
street.sublocations.find_or_create_by(title: '1 дом', location_type:  6, admin_area_id: admin_area.id, non_admin_area_id: non_admin_area.id)
rc.sublocations.find_or_create_by(title: 'Каменка', location_type: 'admin_area')
tc.sublocations.find_or_create_by(title: 'Центр', location_type: 'admin_area')
tc.sublocations.find_or_create_by(title: 'Заречный', location_type: 'admin_area')
tc.sublocations.find_or_create_by(title: 'Восточный', location_type: 'admin_area')
tc.sublocations.find_or_create_by(title: 'Восточный 2', location_type: 'admin_area')
tc.sublocations.find_or_create_by(title: 'Войновка', location_type: 'admin_area')
tc.sublocations.find_or_create_by(title: 'Мыс', location_type: 'admin_area')
tc.sublocations.find_or_create_by(title: 'Маяк', location_type: 'admin_area')
tc.sublocations.find_or_create_by(title: 'Ленина', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Республики', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Комсомольская', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Железнодорожная', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Первомайская', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Кузнецова', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Немцова', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Минская', location_type: 'street')
tc.sublocations.find_or_create_by(title: '50 лет Октября', location_type: 'street')
tc.sublocations.find_or_create_by(title: '50 лет ВЛКСМ', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Салтыкова-Щедрина', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Горького', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Московский тракт', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Червишевский тракт', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Самарцева', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Салаирский тракт', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Старотобольский тракт', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Карла Маркса', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Калинина', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Зои Космодемьянской', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Мориса Тореза', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Профсоюзная', location_type: 'street')
tc.sublocations.find_or_create_by(title: 'Щербакова', location_type: 'street')

agent = User.find_or_create_by(name: 'agent', email: 'agent@black.com')
agent.phones.find_or_create_by(original: '89199992233')

[
    { offer_type: 1, category: 1, property_type: 1,  name: 'Сдам однушку',
      phone: '891912332122', price_from: 100, adv_type: 0, currency: 1, sales_agent: 'test agent', user_id: agent.id },
    { offer_type: 1, category: 1, property_type: 1,
      name: 'Сдам Двухкомнттную',      phone: '891912332133', price_from: 200 , adv_type: 0, currency: 1, sales_agent: 'test agent',
       user_id: agent.id },
    { offer_type: 1, category: 1, property_type: 1,  name: 'Сдам хрущевку',
      phone: '891912332162', price_from: 50,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
       user_id: agent.id },
    { offer_type: 0, category: 1, property_type: 1,
      name: 'Продам однушку', phone: '8919123312311', price_from: 55000,
       adv_type: 0, currency: 1, sales_agent: 'test agent',
        user_id: 1 },
    { offer_type: 0, category: 1, property_type: 1,
      name: 'Продам квартиру-студию. Евроремонт. Торг.', phone: '8919123314512', price_from: 25000,
       adv_type: 0, currency: 1, sales_agent: 'test agent',
        user_id: agent.id },
    { offer_type: 0, category: 6, property_type: 0,
      name: 'Продам офис',
      phone: '892912332122', price_from: 9000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
        user_id: agent.id },
    { offer_type: 0, category: 6, property_type: 0,
      name: 'Продам офисное помещение в районе кривоаанов',
      phone: '892912332122', price_from: 120000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
        user_id: agent.id },
    { offer_type: 4, category: 1, property_type: 1,
      name: 'Куплю хату с краю',
      phone: '896912332122', price_from: 1000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
        user_id: agent.id },
    { offer_type: 4, category: 2, property_type: 1,
      name: 'Куплю дом',
      phone: '541322', price_from: 100000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      user_id: agent.id },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму дом или апартаменты',
      phone: '892200120042', price_from: 1000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      user_id: agent.id },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму коттедж',
      phone: '892200122942', price_from: 10000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      user_id: agent.id },
    { offer_type: 2, category: 2, property_type: 1,
      name: 'Сниму коттедж у реки',
      phone: '892200120064', price_from: 25000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      user_id: agent.id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, отапливаемый',
      phone: '892912334451', price_from: 150000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      user_id: agent.id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, с ямой',
      phone: '892912334457', price_from: 200000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      user_id: agent.id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в центре, охраняемый',
      phone: '892912334459', price_from: 1500000,
      adv_type: 0, currency: 1, sales_agent: 'test agent',
      user_id: agent.id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в центре, неотапиив',
      phone: '892912334459', price_from: 100000,
      adv_type: 0, currency: 1, sales_agent: 'test agent', user_id: agent.id },
    { offer_type: 0, category: 5, property_type: 0,
      name: 'Продам гараж, в за бугром, охраняемый',
      phone: '892912334459', price_from: 1990000,
      adv_type: 0, currency: 1, sales_agent: 'test agent', user_id: agent.id }

].each do |advertisement|
  a = Advertisement.find_or_create_by(advertisement)
  puts "created #{a.errors.messages.to_s}"
end

#ADMIN
User.create(name: 'admin', email: 'admin@admin.ru', password: '12345678', role: :admin)

