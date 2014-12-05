class Api::AdvertisementsController < ApplicationController
  def streets_houses
    @children = Location.suggest_location(params[:parent_id], params[:term])
    render json: @children
  end
end