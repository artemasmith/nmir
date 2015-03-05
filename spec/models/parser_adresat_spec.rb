require 'rails_helper'

RSpec.describe ParserAdresat do

  it "wrong named parse mathod should reurn nil" do
    ParserAdresat.parse_fck_hle('sdfsdfs').should eq(nil)
  end

  it "parse floor should return int" do
    ParserAdresat.parse_floor_from('эт' => '5').should eq(5)
  end

  it "parse year should return string" do
    ParserAdresat.parse_year('год' => '2015').should eq('2015')
  end

  it "parse floor should return nil if string" do
    ParserAdresat.parse_floor_from('эт' => 'dsfd sdfdf').should eq(nil)
  end

end