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
    @alt_adv = Advertisment.search conditions: search_cond
    @alt_adv.delete_if { |a| a.id == @adv.id }
  end

  def edit
  end

  def new
    @adv = Advertisment.new
    @regions = Location.where(location_type: 0)
  end

  def create
    cond = {}
    #What a hell???? cond
    #advertisment_params.each do |k,v|
    #  puts "k= #{k} v=#{v}"
    #  cond[k] = v.to_i if (k == 'category' || k == 'offer_type')
    #  cond[k] = v if (k != 'city' || k != 'region' || k != 'district' || k != 'street' || k != 'address' ) && !v.blank?
    #end
    cond[:comment] = advertisment_params[:comment] if advertisment_params[:comment]
    cond[:private_comment] = advertisment_params[:private_comment] if advertisment_params[:private_comment]
    cond[:city_id] = advertisment_params[:city].to_i if Location.find(advertisment_params[:city].to_i)
    cond[:region_id] = advertisment_params[:region].to_i if Location.find(advertisment_params[:region].to_i)
    cond[:district_id] = advertisment_params[:district].to_i if  Location.find(advertisment_params[:district].to_i)
    street =  Location.find_by_title(advertisment_params[:street])
    cond[:street_id] = street.id if !street.blank?
    address = Location.find_by_title(advertisment_params[:address])
    #Is it right understanding of addres type of locatuion?
    #cond[:address_id] = address.id if !address.blank?
    cond[:currency] = advertisment_params[:currency].blank? ? 0 : advertisment_params[:currency]
    cond[:category] = advertisment_params[:category].to_i
    cond[:offer_type] = advertisment_params[:offer_type].to_i
    cond[:adv_type] = advertisment_params[:adv_type].to_i
    cond[:property_type] = advertisment_params[:property_type].to_i
    cond[:phone] = advertisment_params[:phone] || '12345678'
    cond[:price_from] = advertisment_params[:price_from] || 100000

    #TODO: Solve this!
    cond[:name] = cond[:comment][0..15]
    cond[:sales_agent] = @current_user.name || @current_user.email


    puts("cond=#{cond}")
    log = Logger.new STDOUT
    log.fatal "CONDITIONS= #{cond}"

    @adv = Advertisment.new cond

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

    advertisment_params.each do |k,v|
      search_cond[k] = v.squish.gsub(' ', ' | ') if !v.blank?
    end

    @search_results = Advertisment.search conditions: search_cond
    respond_to do |format|
      format.js
    end
  end



  protected

  def set_location
    @location = params[:location] ? Location.search(conditions: { title: params[:location] }).first : nil
  end

  def find_adv
    @adv = Advertisment.find(params[:id])
  end

  def advertisment_params
    params.permit(:city, :region, :category, :offer_type, :currency, :space_unit, :price_from,
                  :price_to, :date_from, :date_to, :district, :street, :house, :landmark,
                  :floor_from, :space, :room_from, :comment, :private_comment, :phone, :adv_type,
                  :property_type, :address, :space_from, :floor_max)
  end


end
