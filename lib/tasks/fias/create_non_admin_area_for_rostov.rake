namespace :fias do
  desc "create_non_admin_area_for_rostov"
  task create_non_admin_area_for_rostov: :environment do
    rostov = Location.where(title: 'г Ростов-на-Дону').first
    'Автосборочный
    Александровка
    Аэропорт
    Болгарстрой
    Военвед
    ЖДР
    ЗЖМ
    Зоопарк
    Каменка
    Каратаева
    Левый берег
    Ленина площадь
    Ливенцовка
    Нариманова
    Нахичевань
    Новое поселение
    Орджоникидзе
    РИИЖТ
    Ростовское море
    СЖМ
    Сельмаш
    Стройгородок
    Суворовский
    Темерник
    Фрунзе
    Центр
    Чкаловский'.each_line do |line|
      location = Location.new
      location.title = line.to_s.strip
      location.location_type = :non_admin_area
      location.location_id = rostov.id
      location.save
    end
  end
end