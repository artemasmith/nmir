# == Schema Information
#
# Table name: sections
#
#  id                   :integer          not null, primary key
#  advertisements_count :integer          default(0)
#  url                  :string(255)
#  description          :text
#  keywords             :text
#  p                    :text
#  title                :string(255)
#  h1                   :string(255)
#  h2                   :string(255)
#  h3                   :string(255)
#  location_id          :integer
#  offer_type           :integer
#  category             :integer
#  property_type        :integer
#

require 'rails_helper'

RSpec.describe Section, :type => :model do
  fixtures :locations

  subject(:section) { Section.new(
                                  location_id: locations(:city).id, 
                                  offer_type: :buy,
                                  category: :flat
  ) }

  describe 'after save' do
    before { section.save }

    it 'should have generated title' do
      expect(section.title).to eq('куплю квартиру в Ростове')
    end

    it 'should have generated url' do
      expect(section.url).to eq('rostov/kuplyu/kvartiru')
    end
  end



end
