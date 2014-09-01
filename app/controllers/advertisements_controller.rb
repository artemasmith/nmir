class AdvertisementsController < ApplicationController

  before_action :set_location, except: [:new, :create]
  before_action :find_adv, only: [:show, :edit]

  def index
    @neighbors = params[:location] ? get_neighbors(params[:location]) : nil
    @regions = Location.where(location_type: 0)
  end

  def show
    search_cond = { region: @adv.region.id, city: @adv.city.id,
                    adv_type: AdvEnums::ADV_TYPES.index(@adv.adv_type.to_sym),
                    offer_type: AdvEnums::OFFER_TYPES.index(@adv.offer_type.to_sym),
                    category: AdvEnums::CATEGORIES.index(@adv.category.to_sym) }
    @alt_adv = Advertisement.search conditions: search_cond
    @alt_adv.delete_if { |a| a.id == @adv.id }
    @regions = Location.where(location_type: 0)
  end

  def edit
  end

  def new
    @adv = Advertisement.new
    @regions = Location.where(location_type: 0)
  end

  #Awfull chuck of code. Needs to be refactored
  def create
    cond = {}
    #What a hell???? cond
    #advertisement_params.each do |k,v|
    #  puts "k= #{k} v=#{v}"
    #  cond[k] = v.to_i if (k == 'category' || k == 'offer_type')
    #  cond[k] = v if (k != 'city' || k != 'region' || k != 'district' || k != 'street' || k != 'address' ) && !v.blank?
    #end
    cond[:comment] = advertisement_params[:comment] if advertisement_params[:comment]
    cond[:private_comment] = advertisement_params[:private_comment] if advertisement_params[:private_comment]
    cond[:city_id] = advertisement_params[:city].to_i if Location.find(advertisement_params[:city].to_i)
    cond[:region_id] = advertisement_params[:region].to_i if Location.find(advertisement_params[:region].to_i)
    cond[:district_id] = advertisement_params[:district].to_i if  Location.find(advertisement_params[:district].to_i)
    street =  Location.find_by_title(advertisement_params[:street])
    cond[:street_id] = street.id if !street.blank?
    address = Location.find_by_title(advertisement_params[:address])
    #Is it right understanding of addres type of locatuion?
    #cond[:address_id] = address.id if !address.blank?
    cond[:currency] = advertisement_params[:currency].blank? ? 0 : advertisement_params[:currency]
    cond[:category] = advertisement_params[:category].to_i
    cond[:offer_type] = advertisement_params[:offer_type].to_i
    cond[:adv_type] = advertisement_params[:adv_type].to_i
    cond[:property_type] = advertisement_params[:property_type].to_i
    cond[:phone] = advertisement_params[:phone] || '12345678'
    cond[:price_from] = advertisement_params[:price_from] || 100000

    #TODO: Solve this!
    cond[:name] = cond[:comment][0..15]
    cond[:sales_agent] = @current_user.name || @current_user.email


    puts("cond=#{cond}")
    log = Logger.new STDOUT
    log.fatal "CONDITIONS= #{cond}"

    @adv = Advertisement.new cond

    if @adv.save
      respond_to do |format|
        format.html { redirect_to advertisement_path(@adv) }
      end
    else
      render 'new'
    end


  end

  def search
    search_cond = {}

    advertisement_params.each do |k,v|
      search_cond[k] = v.squish.gsub(' ', ' | ') if !v.blank?
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

  def advertisement_params
    params.permit(:city, :region, :category, :offer_type, :currency, :space_unit, :price_from,
                  :price_to, :date_from, :date_to, :district, :street, :house, :landmark,
                  :floor_from, :space, :room_from, :comment, :private_comment, :phone, :adv_type,
                  :property_type, :address, :space_from, :floor_max)
  end


end
