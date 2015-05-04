class Api::AdvertisementsController < ApplicationController
  def autocomlite
    @children = Location.suggest_location(params[:parent_id], params[:term], params[:type])
    render json: @children
  end
end