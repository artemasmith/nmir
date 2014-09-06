module AdvValidation

  extend ActiveSupport::Concern

  PRESENCE_FIELDS = lambda {
    YAML::load(File.open("#{Rails.root}/lib/other/presense_fields.yml")).map(&:to_sym)
  }.call

  included do

    validates_presence_of AdvValidation::PRESENCE_FIELDS
    #:space_unit,
    validates_numericality_of :floor_from, :floor_to, :floor_cnt_from, :floor_cnt_to,
      :space_from, :space_to,  :outdoors_space_from,
      :outdoors_space_to, :outdoors_space_unit, 
      :room_from, :room_to, :price_from, :price_to,
      :unit_price_from, :unit_price_to, :outdoors_unit_price_from, :outdoors_unit_price_to,
      :greater_than_or_equal_to => 0.01, allow_nil: true

    validates :floor_from, :floor_cnt_from, :space_from, 
      :outdoors_space_from, :price_from, :unit_price_from, 
      :outdoors_unit_price_from, :room_from, :'adv_validation/attribute_range' => true
  end
  
  class AttributeRangeValidator < ActiveModel::EachValidator
    # validates each _from attr (price_from)
    # it should be less than _to attr (price_to)
    # and validation should be skipped if _to attr is nil
    def validate_each(record, attribute, value)

      to_attribute = attribute.to_s.match(/(\w+)_from/)[1] + '_to'
      return true if record[to_attribute].nil? || value.nil?

      if record[attribute] > record[to_attribute]
        record.errors.add attribute, "Должно быть меньше максимального значения"  
      end
    end
  end
end
