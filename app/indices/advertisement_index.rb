
ThinkingSphinx::Index.define :advertisement,
                             :with => :active_record,
                             :delta => ThinkingSphinx::Deltas::DatetimeDelta,
                             :delta_options => {:threshold => 1.hour, :column => :changed_at} do
  # fields
  indexes :id, sortable: true
  indexes name, sortable: true
  indexes phone, sortable: true
  indexes comment, sortable: true
  indexes locations.title, :as => :location_titles, sortable: true
  has locations.id, :as => :location_ids
  ['created_at', 'updated_at', 'price_from', 'price_to', 'adv_type', 'property_type', 'category', 'offer_type', 'mortgage', 'not_for_agents'].each do |m|
    has m, as: m
  end
end


