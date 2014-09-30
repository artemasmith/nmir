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
    @grouped_allowed_attributes =  @adv.grouped_allowed_attributes
  end

  def edit
  end

  def new
    @adv = Advertisement.new
    @adv.photos.build
    user = @adv.build_user
    user.phones.build
    @regions = Location.where(location_type: 0)
    @locations = Location.where(location_type: 0).map{ |l| { title: l.title, id: l.id, multi: 'radio', type: l.location_type } }
  end

  #returns array of children locations and render it in the modal by js
  def get_locations
    if params[:parent_id].to_i != 0
      @children = Location.find(params[:parent_id].to_i).children_locations
    else
      @children = Location.where('location_type =?',0)
    end
    @children = @children.map{ |l| { id: l.id, title: l.title, multi: params[:multi],  type: l.location_type } }
  end

  #returns array of hashed children location to render when we selected parent location
  def add_child_locations
    #TODO make tree check before rendering - and delete will be remove location and re-rendering buttons
    #multi = params[:multi]
    @locations = []
    log = Logger.new STDOUT
    ungrouped_locations = []
    params[:locations].split(',').each do |l|
      loc = Location.find(l.to_i)
      ungrouped_locations << loc if loc.present?
    end
    ungrouped_locations.sort_by{|l| l.location_type}.reverse!
    grouped_locations = []
    ungrouped_locations.each { |l| Location.group_location(l, ungrouped_locations, grouped_locations) }

    grouped_locations.each do |loc|
      h_c = loc.children_locations.present?
      cls = h_c ? 'ShowChildren' : 'location'
      @locations << { type: loc.location_type, id: loc.id, title: loc.title, has_children: h_c,
                      cls: cls, multi: params[:multi], parent_id: loc.location_id, can_delete: true }
    end

    params[:locations].split(',').each do |l|
      loc = Location.find(l.to_i)
      if loc.present?
        h_c = loc.children_locations.present?
        cls = h_c ? 'ShowChildren' : 'location'
        @locations << { type: loc.location_type, id: loc.id, title: loc.title, has_children: h_c,
                        cls: cls, multi: params[:multi], parent_id: loc.location_id, can_delete: true }
      end
    end
    @locations.uniq!
  end

  def get_attributes
    adv = Advertisement.new(category: params[:category].to_sym, adv_type: params[:adv_type].to_sym)
    @grouped_allowed_attributes = adv.grouped_allowed_attributes
    @allowed_attributes = adv.allowed_attributes
  end

  def create
    @locations = Location.where(location_type: 0)
    if can? :create_from_admin, Advertisement
      if advertisement_params[:user_id].blank?
        @adv = Advertisement.new advertisement_params
      else
        @adv = User.find(advertisement_params[:user_id].to_i).advertisements.new advertisement_params
      end
    else
      @adv = current_user.advertisements.new advertisement_params
    end

    if @adv.save
      redirect_to advertisement_path(@adv)
    else
      render 'advertisements/new'
    end
  end

  def check_phone
    @advertisements = Advertisement.
        joins('INNER JOIN "phones" ON "advertisements"."user_id" = "phones"."user_id"').
        where('phones.number' => params[:phones].split(',').map{|phone| Phone.normalize(phone)}).
        all
    @user_id = User.where('email = ?', params[:email]).first.try :id if params[:email].present?
    @user_id ||= @advertisements.first.try :user_id
  end

  def search
    search_cond = {}
    with_cond = {}
    from = search_params[:price_from].to_i
    to = search_params[:price_to].to_i
    if !from.blank?
      with_cond[:price_from] = to.blank? ? from..99990000 : from..to
    end

    #locations = ['region_id','admin_area_id', 'non_admin_area_id', 'city_id','district_id', 'street_id', 'address_id', 'landmark_id']

    search_params.each do |k,v|
      if k != 'price_from' && k != 'price_to'
        if v.class == Array
          search_cond[k] = v.map{|i| i = i.squish.gsub(' ',' | ')}.join(' | ')
        else
          search_cond[k] = v.squish.gsub(' ', ' | ') unless v.blank?
        end
      end
    end

    @search_results =  with_cond.blank? ? Advertisement.search(conditions: search_cond) : Advertisement.search(conditions: search_cond, with: with_cond)
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
    params.permit(:category, :offer_type, :price_from,
                  :price_to, :not_for_agents, :date_from, :date_to, :district_id, :street_id, :house_id,
                  :floor_from, :space, :room_from, :comment, :private_comment, :phone, :landmark_id,
                  :property_type, :floor_cnt_from, :address_id, :space_from, :floor_max, :mortgage, :district_id, :city_id, adv_type: [],
                  offer_type: [], category: [])
  end

  def advertisement_params
    params.require(:advertisement).permit(:city_id, :region_id, :district_id, :category, :offer_type, :price_from,
    :price_to, :not_for_agents, :date_from, :date_to, :district, :street, :house, :user_id,
    :floor_from, :space, :room_from, :comment, :private_comment, :phone, :adv_type, :latitude, :longitude,
    :property_type, :floor_cnt_from, :address, :space_from, :floor_max, :mortgage, district: [], city: [], adv_type: [],
    offer_type: [], category: [], photos_attributes: [:id, :description, :filename, :file],
    user_attributes: [:name, :password, :email, phones_attributes: [:id, :original, :_destroy] ])
  end


end
