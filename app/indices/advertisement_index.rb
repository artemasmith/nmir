ThinkingSphinx::Index.define :advertisement,
                             :with => :active_record,
                             :delta => ThinkingSphinx::Deltas::DatetimeDelta do
  # fields
  indexes :id, sortable: true
  indexes name, sortable: true
  indexes phone, sortable: true
  indexes comment, sortable: true
  indexes landmark, sortable: true
  indexes locations.title, :as => :location_titles, sortable: true
  has locations.id, :as => :location_ids
  %w(created_at updated_at price_from price_to adv_type property_type category offer_type mortgage not_for_agents status_type floor_from floor_cnt_from space_from outdoors_space_from floor_to floor_cnt_to space_to outdoors_space_to room_from room_to user_role).each do |m|
    has m, as: m
  end
end


