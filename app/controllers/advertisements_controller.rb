class AdvertisementsController < ApplicationController

  before_action :set_location, except: [:new, :create]
  def index
    @neighbors = params[:location] ? get_neighbors(params[:location]) : nil
    @regions = Location.where(location_type: 0).map { |l| [l.title, l.id] }

  end

  def show
  end

  def edit
  end

  def new
  end

  def search
    #TODO figure out how to sanitize user input??
    search_cond = {}

    advertisment_params.each do |k,v|
      search_cond[k] = v.squish.gsub(' ', ' | ') if !v.blank?
    end

    @search_results = Advertisment.search(conditions: search_cond)
    respond_to do |format|
      format.js
    end
  end



  protected

  def set_location
    @location = params[:location] ? Location.search(conditions: { title: params[:location] }).first : nil
  end
  def advertisment_params
    params.permit(:city, :region, :category, :offer_type, :currency, :space_unit, :price_from,
                                       :price_to, :date_from, :date_to)
  end


end
