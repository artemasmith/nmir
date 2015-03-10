require 'rails_helper'

RSpec.describe ParserAdresat do

  let(:row) { ["квартира",	'3450',	'ЗЖМ',	'Рыбак Дона',	2,	1,	10,	'кир',	60,	36,	12,	2.7,
               'разд',	0, '?',	'м/пласт',	'бабочка',	'стройвар',	2015,	'АДРЕСАТ',
               '#165294',	 'Жмайлова, 4е | Эдуард-   89185674466 | торг,закр.двор,переуступка',	'25-02-2015'
  ] }
  let(:titles) { { "РЕЗУЛЬТАТ ПОИСКА: Ростов-на-Дону г   Раздел:ПРОДАЮ КВАРТИРЫ найдено заявок: 60.Объект" => 0,
                   "цена" => 1,	"район" => 2,	"ориентир" => 3,	"ком" => 4,	"эт" => 5,	"э-н" => 6,	"стены" => 7,
                   "Sоб" => 8,	"Sж" => 9,	"Sк" => 10,	"hп.1" => 11,	"су" => 12,	"т" => 13,	"бал" => 14,
                   "окна" => 15,	"план.1" => 16,	"отд.хар" => 17,	"год" => 18,	"БД" => 19, number: 20, comment: 21
  }  }

  describe "correct input provided " do

    it { ParserAdresat.parse_floor_from(row, titles).should eq(1) }
    it { ParserAdresat.parse_floor_cnt_from(row, titles).should eq(10) }
    it { ParserAdresat.parse_price(row, titles).should eq(3450.0) }
    it { ParserAdresat.parse_room_from(row, titles).should eq(2) }
    it { ParserAdresat.parse_space_from(row, titles).should eq(60.0) }
    it { ParserAdresat.parse_landmark(row, titles).should eq('Рыбак Дона') }

    it { ParserAdresat.parse_year(row, titles).should eq('2015') }
    it { ParserAdresat.parse_balcony(row, titles).should eq('не указано') }
    it { ParserAdresat.parse_windows(row, titles).should eq('металопластик') }
    it { ParserAdresat.parse_char(row, titles).should eq('строй вариант') }
    it { ParserAdresat.parse_walls(row, titles).should eq('кирпич') }
    it { ParserAdresat.parse_bath(row, titles).should eq('раздельный') }
    it { ParserAdresat.parse_blueprint(row, titles).should eq('бабочка') }
  end

  describe "predefined parsing functions" do

    let(:titles2) { { "РЕЗУЛЬТАТ ПОИСКА: Ростов-на-Дону г   Раздел:ПРОДАЮ ДОМА найдено заявок: 33.Объект" => 0 }}
    let(:titles3){{ "РЕЗУЛЬТАТ ПОИСКА: Ростов-на-Дону г   Раздел:ПРОДАЮ УЧАСТКИ найдено заявок: 14.Объект" => 0 }}

    it { ParserAdresat.parse_offer_type(titles).should eq(:sale) }
    it { ParserAdresat.parse_category(titles).should eq(:flat) }
    it { ParserAdresat.parse_category(titles2).should eq(:house) }
    it { ParserAdresat.parse_category(titles3).should eq(:ijs) }
    it { ParserAdresat.parse_adv_type(titles).should eq(:offer) }

  end

  describe "incorrect input" do

    it { ParserAdresat.parse_something(row, titles).should eq(nil) }
    it { ParserAdresat.parse_floor_from(row).should eq(nil) }
    it { ParserAdresat.parse_floor_from().should eq(nil) }
    it { ParserAdresat.parse_floor_from("sdfsdfsd").should eq(nil) }

  end




end