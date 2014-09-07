class AdvertisementsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_location, except: [:new, :create]
  before_action :find_adv, only: [:show, :edit]

  def index
    @neighbors = params[:location] ? get_neighbors(params[:location]) : nil
    @regions = Location.where(location_type: 0)
  end

  def show
    @photos = @adv.photos
    @today_counter, @all_days_counter = AdvertisementCounter.get_and_increase_count_for_adv(@adv.id)
    @allowed_attributes =  @adv.allowed_attributes

    # search_cond = { region: @adv.region.id,
    #                 city: @adv.city.id,
    #                 adv_type: AdvEnums::ADV_TYPES.index(@adv.adv_type.to_sym),
    #                 offer_type: AdvEnums::OFFER_TYPES.index(@adv.offer_type.to_sym),
    #                 category: AdvEnums::CATEGORIES.index(@adv.category.to_sym)
    # }
    # search_cond = {}
    # @alt_adv = Advertisement.search conditions: search_cond
    # @alt_adv.delete_if { |adv| adv.id == @adv.id }
    # @regions = Location.where(location_type: 0)
  end

  def edit
  end

  def new
    @adv = Advertisement.new
    @regions = Location.where(location_type: 0)
  end

  def get_attributes
    @allowed_attributes = Advertisement.new(category: params[:category].to_i, adv_type: params[:adv_type].to_i).allowed_attributes

    respond_to do |format|
      format.js
    end
  end

  def create
    @regions = Location.where(location_type: 0)
    @adv = @current_user.advertisements.new advertisement_params

    if @adv.save
      respond_to do |format|
        format.html { redirect_to advertisement_path(@adv) }
      end
    else
      render :new
    end
  end

  def search
    search_cond = {}

    search_params.each do |k,v|
      if v.class == Array
        search_cond[k] = v.map{|i| i = i.squish.gsub(' ',' | ')}.join(' | ')
      else
        search_cond[k] = v.squish.gsub(' ', ' | ') if !v.blank?
      end

    end

    @search_results = Advertisement.search(conditions: search_cond)
    respond_to do |format|
      format.js
    end
  end



  protected

  def set_location
    @location = params[:location] ? Location.search(conditions: { title: params[:location] }).first : nil
  end

  def find_adv
    @adv = Advertisement.find(params[:id])
  end

  def search_params
    params.permit(:category, :offer_type, :currency, :space_unit, :price_from,
                  :price_to, :not_for_agents, :date_from, :date_to, :district, :street, :house,
                  :floor_from, :unit_price_from, :space, :room_from, :comment, :private_comment, :phone,
                  :property_type, :floor_cnt_from, :address, :space_from, :floor_max, :mortgage, district: [], city: [], adv_type: [],
                  offer_type: [], category: [])
  end

  def advertisement_params
    params.require(:advertisement).permit(:city_id, :region_id, :district_id, :category, :offer_type, :currency, :space_unit, :price_from,
                  :price_to, :not_for_agents, :date_from, :date_to, :district, :street, :house,
                  :floor_from, :unit_price_from, :space, :room_from, :comment, :private_comment, :phone, :adv_type,
                  :property_type, :floor_cnt_from, :address, :space_from, :floor_max, :mortgage, district: [], city: [], adv_type: [],
                  offer_type: [], category: [])
  end


end
