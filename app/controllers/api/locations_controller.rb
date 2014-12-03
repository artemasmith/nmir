class Api::LocationsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource
  def create
    parent = Location.find(location_params[:location_id])
    location = parent.children_locations.where(location_type: Location.location_types[location_params[:location_type]]).where(title: location_params[:title].to_s.strip).first
    if location.blank?
      parent.loaded_resource = false
      parent.save!
      location = Location.new location_params
      location.status_type = current_user.present? && current_user.admin? ? :checked : :unchecked
      location.save!
    end
    render js: {
        id: location.id,
        has_children: location.has_children?,
        location_type: location.location_type,
        title: location.title
    }.to_json
  end

  def location_params
    params.require(:location).permit(:title, :location_type, :location_id)
  end
end
