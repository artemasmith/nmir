module AdvRailsAdmin

  extend ActiveSupport::Concern


  included do

    rails_admin do
      # edit do
        field :adv_type, :enum do
          enum do
            AdvEnums::ADV_TYPES.each_with_index.map { |i,j| [i,j]}
          end
        end
        field :category, :enum do
          enum do
            AdvEnums::CATEGORIES.each_with_index.map { |i,j| [i,j]}
          end
        end
        field :property_type, :enum do
          enum do
            AdvEnums::PROPERTY_TYPES.each_with_index.map { |i,j| [i,j]}
          end
        end
        field :offer_type, :enum do
          enum do
            AdvEnums::OFFER_TYPES.each_with_index.map { |i,j| [i,j]}
          end
        end
        field :distance, :integer
        field :time_on_transport, :integer
        field :time_on_foot, :integer
        field :agency_id, :integer
        field :floor_from, :integer
        field :floor_to, :integer
        field :floor_cnt_from, :integer
        include_all_fields
      # end
    end
  end
end
