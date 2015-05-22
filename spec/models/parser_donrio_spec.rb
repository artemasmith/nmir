require 'rails_helper'

RSpec.describe ParserDonrio do

  let(:row) {[ '1 дек', '1720', '1', '2 Ордж.', 'Туполева/Травяная', 'ц/5к', '35м',
               %w(1 ком. изолированную квартиру со всеми удобствами на 2 пос. Орджоникидзе, р-он Туполева,
цок/5 кирп., окна выше уровня земли, спальня-16,6 кв.м., кухня-11,8 кв.м.,
с/уз-совмещен, потолки-натяжные, полы-деревянные. Дому 4 года. По документам-нежилое помеще  10.04.2014-1750т.р.),
               'Елена(961)306-00-47'
  ]}
  let(:titles) { { "Дата" => 0, "Цена" => 1, "ком." => 2, "Район" => 3, "Адрес" => 4, "Эт." => 5, "Площадь" => 6,
    "Хар" => 7, "Тел контанк" => 8
  } }

  let(:titles2) {{ "Дата" => 0, "Цена" => 1, "Sуч.Всотках" => 2, "Район" => 3, "Адрес" => 4, "ком." => 5, "Эт." => 6, "Площадь" => 7,
                   "Хар" => 8, "Тел контанк" => 9
  }  }

  let(:row2){ [ '31 дек', '2000', '1,5с', '2 Ордж.', 'Глинки/Арефьева', '3', 'кирп', '50м2 ',
                %w(часть дома 50 м2, отдельный двор, въезд для а/м, двор асф, 3 комн, подвал, чердак,
 в/у и коммун, в доме, центр, канал, окна м/п, телеф, Интернет, докум. готовы.),
                '«8-909-428-37-30 Виктория'
  ] }

  describe "correct input for flat provided" do
    it { ParserDonrio.parse_name_and_phone(row,titles).should eq(["Елена", "+79613060047", 0]) }
    it { ParserDonrio.parse_space_from(row,titles).should eq(35) }
    it { ParserDonrio.parse_price(row).should eq(1720000) }
    it { ParserDonrio.parse_floor_from(row,titles).should eq(0) }
    it { ParserDonrio.parse_floor_cnt_from(row,titles).should eq(5) }
    it { ParserDonrio.parse_category(row,titles).should eq(:flat) }

    describe "house correct input" do
      it { ParserDonrio.parse_name_and_phone(row2,titles2).should eq(["Виктория", "89094283730", 0]) }
      it { ParserDonrio.parse_space_from(row2,titles2).should eq(50) }
      it { ParserDonrio.parse_price(row2).should eq(2000000) }
      it { ParserDonrio.parse_floor_from(row2,titles2).should eq(nil) }
      it { ParserDonrio.parse_floor_cnt_from(row2,titles2).should eq(nil) }
      it { ParserDonrio.parse_category(row2,titles2).should eq(:house) }
    end

  end

  describe "agent in contact row (flat)" do
    let(:titles3){ { "Тел контанк" => 0 }}
    let(:row3){[ '(908)516-82-27" Валерия агент на % не претендует' ]}

    it { ParserDonrio.parse_name_and_phone(row3, titles3).should eq(['Валерия', '+79085168227', 1]) }

    describe "house agent in contact" do
      let(:row4){ [ '(904)443-22-50 агент на % не претендует"' ] }

      it { ParserDonrio.parse_name_and_phone(row4, titles3).should eq(['', '+79044432250', 1]) }
    end
  end


end