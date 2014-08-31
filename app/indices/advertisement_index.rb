ThinkingSphinx::Index.define :advertisement, :with => :active_record do
  # fields
  indexes :id, sortable: true
  indexes name, sortable: true
  indexes phone, sortable: true
  indexes price_from, type: :integer, sortable: true
  indexes price_to, type: :integer, sortable: true
  indexes floor_from, type: :integer, sortable: true
  indexes floor_to, type: :integer, sortable: true
  indexes space_from, type: :decimal, sortable: true
  indexes space_to, type: :decimal, sortable: true
  indexes category, sortable: true
  indexes offer_type, sortable: true
  indexes space_unit
  indexes currency
  indexes keywords
  indexes comment
  indexes region.id, as: :region, sortable: true
  indexes region.title, as: :region_title, sortable: true
  indexes district.title, as: :adv_district, sortable: true
  indexes city.title, as: :city_title, sortable: true
  indexes city.id, as: :city, sortable: true
  indexes admin_area.title, as: :admin_area, sortable: true
  indexes non_admin_area.title, as: :non_admin_area, sortable: true
  indexes street.title, as: :street, sortable: true
  indexes address.title, as: :address, sortable: true
  indexes landmark.title, as: :landmark

  # attributes
  has created_at, updated_at
end