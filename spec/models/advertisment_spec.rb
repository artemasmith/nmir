# == Schema Information
#
# Table name: advertisments
#
#  id                       :integer          not null, primary key
#  offer_type               :integer          not null
#  property_type            :integer          not null
#  category                 :integer          not null
#  agent_category           :integer
#  currency                 :integer
#  distance                 :integer
#  time_on_transport        :integer
#  time_on_foot             :integer
#  agency_id                :integer
#  floor_from               :integer
#  floor_to                 :integer
#  floor_cnt_from           :integer
#  floor_cnt_to             :integer
#  expire_date              :datetime
#  payed_adv                :boolean          default(FALSE)
#  manually_added           :boolean
#  not_for_agents           :boolean
#  mortgage                 :boolean          default(FALSE)
#  name                     :string(255)
#  sales_agent              :string(255)
#  phone                    :string(255)
#  organization             :string(255)
#  space_unit               :string(255)
#  outdoors_space_from      :decimal(15, 2)
#  outdoors_space_to        :decimal(15, 2)
#  outdoors_space_unit      :string(255)
#  price_from               :integer
#  price_to                 :integer
#  unit_price_from          :decimal(15, 2)
#  unit_price_to            :decimal(15, 2)
#  outdoors_unit_price_from :integer
#  outdoors_unit_price_to   :integer
#  space_from               :decimal(15, 2)
#  space_to                 :decimal(15, 2)
#  keywords                 :text
#  created_at               :datetime
#  updated_at               :datetime
#  landmark                 :string(255)
#  comment                  :text
#  private_comment          :text
#  adv_type                 :integer
#  region_id                :integer
#  district_id              :integer
#  city_id                  :integer
#  admin_area_id            :integer
#  non_admin_area_id        :integer
#  street_id                :integer
#  address_id               :integer
#  landmark_id              :integer
#  room_from                :integer
#  room_to                  :integer
#

require 'rails_helper'
include AdvSpecHelper

RSpec.describe Advertisment, :type => :model do
  fixtures :locations

  subject(:adv) { AdvSpecHelper.new_adv }

  describe 'has many attributes and' do

    AdvSpecHelper.adv_attr_list.each do |attr|
      it { expect(adv).to respond_to(attr) }
    end 
  end

  describe 'with specific offer type' do
    before { adv.offer_type = :day }

    # category validation depending on Conformity table. see lib/other/adv_conformity.yml
    it 'and invalid category' do
      adv.category = :ijs
      expect(adv).not_to be_valid
    end

    it 'and valid category' do
      adv.category = :flat
      expect(adv).to be_valid
    end

    it 'and valid property_type' do
      adv.property_type = :residental
      expect(adv).to be_valid
    end

    it 'and valid property_type' do
      adv.property_type = :commerce
      expect(adv).not_to be_valid
    end
  end

  describe 'has required fields' do
    it 'and with filled fields' do
      expect(adv).to be_valid
    end

    # checks presence of all fields, specified in a file. see lib/other/presense_fields.yml
    AdvValidation::PRESENCE_FIELDS.each do |field|
      it "and without #{field}" do
        adv[field] = nil
        expect(adv).not_to be_valid
      end
    end
  end

  describe 'has range (_from _to) attributes and' do
    # Validate, that _from attr is less than _to attr
    # price_from < price_to
    AdvSpecHelper.from_methods.each do |from_method|
      
      # compute _to method. price_from becomes price_to
      let(:to_method) { from_method.match(/(\w+)_from/)[1] + '_to' }

      it "with #{from_method} greater than it's _to attribute" do
        adv[from_method] = 1000

        expect(adv).not_to be_valid
      end

      it "when _to attribute set to nil" do
        adv[to_method] = nil

        # if price_to is nil, then we should skip this validation
        expect(adv).to be_valid
      end

      # should respond to attr without '_from' - price_for - price 
      it do 
        method_without_from = from_method.match(/(\w+)_from/)[1].to_sym
        expect(adv).to respond_to(method_without_from)
      end

      # and should return price_from value
      it do 
        method_without_from = from_method.match(/(\w+)_from/)[1].to_sym
        expect(adv.send(method_without_from)).to eq(adv.send(from_method.to_sym))
      end
    end
  end

  describe 'is binded to locations and' do

    before do 
      #adv.region = locations :region
      #adv.district = locations :district
      #adv.city = locations :city
      #adv.admin_area = locations :admin_area
      #adv.non_admin_area = locations :non_admin_area
      #adv.street = locations :street
      #adv.address = locations :address
      adv.landmark = locations :landmark
      adv.save 
    end

    let(:region) { locations :region }
    let(:district) { locations :district}
    let(:city) { locations :city }
    let(:admin_area) { locations :admin_area}
    let(:non_admin_area) { locations :non_admin_area}
    let(:street) { locations :street}
    let(:address) { locations :address}
    let(:landmark) { locations :landmark}

    specify { expect(adv.region(true)).to eq(region); } 
      
    specify { expect(adv.district(true)).to eq(district) } 
    specify { expect(adv.city(true)).to eq(city) } 
    specify { expect(adv.street(true)).to eq(street) } 
    specify { expect(adv.address(true)).to eq(address) } 
    specify { expect(adv.landmark(true)).to eq(landmark) } 

  end


end



