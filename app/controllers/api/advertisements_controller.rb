class Api::AdvertisementsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :streets_houses]
  def show
    @advertisement = Advertisement.find(params[:id])
    render js: {name: @advertisement.name, phone: @advertisement.phone}.to_json
  end

  def streets_houses
    @children = Location.suggest_location(params[:parent_id], params[:term])
    render json: @children
  end
end