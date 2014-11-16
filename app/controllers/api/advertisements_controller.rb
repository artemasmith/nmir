class Api::AdvertisementsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :streets_houses]
  def show
    @advertisement = Advertisement.find(params[:id])
    render js: {name: @advertisement.name, phone: @advertisement.phone}.to_json
  end

  def streets_houses
    @children = Location.where(location_id: params[:parent_id].to_i).where('title like ?', "%_#{params[:term]}_%")
    @children = @children.map{ |l| { label: l.title, value: l.id, has_children: l.has_children? } }
    render json: @children
  end
end