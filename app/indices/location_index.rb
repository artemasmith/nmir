ThinkingSphinx::Index.define :location, :with => :active_record do
  # fields
  indexes :id, sortable: true
  indexes title, sortable: true
  indexes translit
  indexes location_type
  indexes parent_location.title, as: :parent_title
  #maybe we should not indecing parents ids
  indexes parent_location.id, as: :parent_id

  # attributes
  has location_id
end
