# == Schema Information
#
# Table name: phones
#
#  id       :integer          not null, primary key
#  number   :string(255)
#  original :string(255)
#  user_id  :integer
#

require 'rails_helper'

RSpec.describe Phone, :type => :model do
  describe 'must be converted from city number to mobile' do
    subject(:phone) { Phone.new }

    describe 'Megaphone' do
      it '8-863-226-* >> 8-928-226-*' do
        phone.original = '8-863-226-11-22'
        phone.save
        expect(phone.number).to eq('+79282261122')
      end
      
      it '8-863-229-* >> 8-928-229-*' do
        phone.original = '8-863-229-11-22'
        phone.save
        expect(phone.number).to eq('+79282291122')
      end
      
      it '8-863-296-* >> 8-928-296-*' do
        phone.original = '8-863-296-11-22'
        phone.save
        expect(phone.number).to eq('+79282961122')
      end

      it '8-863-270-* >> 8-928-270-*' do
        phone.original = '8-863-270-11-22'
        phone.save
        expect(phone.number).to eq('+79282701122')
      end
      
      it '8-863-279-* >> 8-928-279-*' do
        phone.original = '8-863-279-11-22'
        phone.save
        expect(phone.number).to eq('+79282791122')
      end
    end

    describe 'MTS' do
      it '8-863-275-* >> 8-918-555-*' do
        phone.original = '8-863-275-11-22'
        phone.save
        expect(phone.number).to eq('+79185551122')
      end

      it '8-863-294-* >> 8-918-554-*' do
        phone.original = '8-863-294-11-22'
        phone.save
        expect(phone.number).to eq('+79185541122')
      end
      
      it '8-863-298-* >> 8-918-558-*' do
        phone.original = '8-863-298-11-22'
        phone.save
        expect(phone.number).to eq('+79185581122')
      end
    end

    describe 'Beeline' do
      it '8-863-256-* >> 8-903-406-*' do
        phone.original = '8-863-256-11-22'
        phone.save
        expect(phone.number).to eq('+79034061122')
      end

      it '8-863-221-* >> 8-903-401-*' do
        phone.original = '8-863-221-11-22'
        phone.save
        expect(phone.number).to eq('+79034011122')
      end
    end
  end
    
  describe 'with existing number' do
    subject(:phone) { Phone.new }

    before(:all) do 
      Phone.create(original: '8-863-229-11-22')
    end 

    it 'with same phone'  do
      phone.original = '8-863-229-11-22'
      expect(phone).not_to be_valid
    end
  end

  describe 'has original and normalized number.' do
    subject(:phone) { Phone.new }

    it { expect(phone).to respond_to(:original) }
    it { expect(phone).to respond_to(:number) }

    describe 'Before save it should be normalized' do

      it 'with "-" "( )" " " "_" delimiters' do
        phone.original = '8(928)  251_11-22'
        phone.save
        expect(phone.number).to eq('+79282511122') 
      end

      it 'wthout city/mobile code' do
        phone.original = '226- 11 - 11'
        # это значит что пишем его и номализуем его по алгоритму 
        # 226- 11 - 11 -> 8-863-226- 11 - 11 -> 8-928-226- 11- 11 ->  +79282261111
        phone.save
        expect(phone.number).to eq('+79282261111') 
      end

      it 'wthout city/mobile code and frist "2" ' do
        phone.original = '26- 11 - 11'
        # добавляем два вначале, а потом преобразуем к номальному номеру
        phone.save
        expect(phone.number).to eq('+79282261111') 
      end

      it 'normal number wthout city/mobile code and frist "2" ' do
        phone.original = '44- 11 - 11'
        phone.save
        expect(phone.number).to eq('+78632441111') 
      end

      it 'with 10-character number' do
        phone.original = '908 508-5077'
        phone.save
        expect(phone.number).to eq('+79085085077')
      end

    end
    
  end

end
