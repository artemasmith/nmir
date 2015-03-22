# == Schema Information
#
# Table name: locations
#
#  id                :integer          not null, primary key
#  title             :string(255)
#  translit          :string(255)
#  location_type     :integer
#  location_id       :integer
#  children_count    :integer          default(0)
#  aoguid            :string(255)
#  parentguid        :string(255)
#  admin_area_id     :integer
#  non_admin_area_id :integer
#  city_id           :integer
#  loaded_resource   :boolean          default(FALSE), not null
#  status_type       :integer          default(0)
#

require 'rails_helper'

RSpec.describe Location, :type => :model do
  fixtures :locations
  subject(:location) { locations(:city) }

  specify { expect(location).to respond_to(:title, :translit, :location_type, :parent_location, :sublocations) }

  it 'translit method to return transliterated title' do
    location.save
    expect(location.translit).to eq('rostov')
  end

  describe 'has selfjoined relations' do
    # see fixture
    let(:street) { locations(:street) }
    let(:district) { locations(:district) }

    it 'with sublocations' do
      expect(location.sublocations.first).to eq(street)
    end

    it 'with parent_location' do
      expect(location.parent_location).to eq(district)
    end
  end

  describe 'has neighborhoods.' do
    let(:street) { locations(:street) }
    let(:district) { locations(:district) }

    before { location.neighbors << [ street, district ] } 

    it 'can add new neighbors' do
      expect(location.neighbors.count).to eq(2)
    end

    it 'dont have inverse relation' do
      expect(street.neighbors.count).to eq(0)
    end
  end

  describe 'has some methods' do
    let(:address) { locations(:address) }
    it 'parent_locations method should return all parent nodes' do
      p_l = Location.parent_locations(address)
      expect(p_l).to be_kind_of(Array)
    end
  end

  describe 'has #locative method' do
    it 'should return correct locative form' do
      expect(Russian.locative(location.title)).to eq('Ростове')
    end
    
    it 'should return correct locative form' do
      location.title = 'Москва'
      expect(Russian.locative(location.title)).to eq('Москве')
    end
    
    it 'should return correct locative form' do
      location.title = 'Синявское'
      expect(Russian.locative(location.title)).to eq('Синявском')
    end
    
    it 'should return correct locative form' do
      location.title = 'Новоминская'
      expect(Russian.locative(location.title)).to eq('Новоминской')
    end
    
    it 'should return correct locative form' do
      location.title = 'Сочи'
      expect(Russian.locative(location.title)).to eq('Сочи')
    end

    it 'should return correct locative form' do
      location.title = 'Комсомольский'
      expect(Russian.locative(location.title)).to eq('Комсомольском')
    end

    it 'should return correct locative form' do
      location.title = 'Казань'
      expect(Russian.locative(location.title)).to eq('Казани')
    end

    it 'should return correct locative form' do
      location.title = 'Радужный'
      expect(Russian.locative(location.title)).to eq('Радужном')
    end
  end

end
