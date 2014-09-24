class Api::AdvertisementsController < ApplicationController
  before_action :authenticate_user!
  def show
    @advertisement= Advertisement.find(params[:id])
    render js: {name: @advertisement.name, phone: @advertisement.phone}.to_json
  end

  def index
    if params[:parent_id].to_i != 0
      @children = Location.find(params[:parent_id].to_i).children_locations
    else
      @children = Location.where('location_type =?',0)
    end
    render json: @children.map{ |l| { label: l.title, id: l.id } }
  end

end