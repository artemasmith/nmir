class AdvertisementsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_location, except: [:new, :create]
  before_action :find_adv, only: [:show, :edit, :update]
  load_and_authorize_resource except: [:get_locations, :get_attributes]


  def index

    params[:advertisement] = {} if params[:advertisement].blank?

    #clear

    if params[:url].blank?
      offer_type = search_params[:offer_type].first if search_params[:offer_type].present? && search_params[:offer_type].size == 1
      category = search_params[:category].first if search_params[:category].present? && search_params[:category].size == 1

      property_type = AdvEnums::PROPERTY_TYPES.index(:residental) if search_params[:category].present? && ('0'..'5').to_a.sort == search_params[:category].sort
      property_type = AdvEnums::PROPERTY_TYPES.index(:commerce) if search_params[:category].present? && ('6'..'11').to_a.sort == search_params[:category].sort

      load_location_state!()

      child_location_ids = []
      @locations.each do |m|
        child_location_ids << m if @locations.find{|n| n.location_id == m.id}.blank?
      end

      location_id = child_location_ids.first if child_location_ids.size == 1
      @section = Section.where(offer_type: offer_type, category: category, location_id: location_id, property_type: property_type).first

      if @section.present?
        if @section.url != '/'
          params[:advertisement].delete_if{|e| params[:advertisement][e].blank?}
          params.delete :utf8
          [:action, :controller].each { |m| params.delete(m) }
          [:offer_type, :category, :location_ids, :property_type].each { |m| params[:advertisement].delete(m) }
          params.delete :advertisement if params[:advertisement].empty?
          build_nested_query = Rack::Utils.build_nested_query(params)
          redirect_to "#{@section.url}#{build_nested_query.present? ? "?#{build_nested_query}" : ''}" and return
        end
      end

      @root_section = @section.presence || Section.where(offer_type: nil, category: nil, location_id: nil, property_type: nil).first

    else
      @root_section = @section = Section.where(url: "/#{params[:url]}").first
      if @root_section.blank?
        raise ActionController::RoutingError.new("Not Found #{params[:url]}")
      end
      load_location_state!(@section.present? && @section.location_id ? Location.parent_locations(Location.find(@section.location_id)) : nil)
    end

    @neighbors = nil

    with = {}
    conditions = {}
    options = {
        :conditions => conditions,
        :with => with,
        :order => 'updated_at DESC',
        :classes => [Advertisement]
    }

    @limit = (params[:per_page].presence || 10).to_i

    params[:page] ||= 1
    options[:page] = (params[:page] || 1).to_i
    options[:per_page] = @limit


    if @section.present?
      [:offer_type, :category].each do |m|
        with[m] =  [@section.attributes[m.to_s]] if @section.attributes[m.to_s].present?
      end
      with[:property_type] =  AdvEnums::PROPERTY_TYPES.index(@section.property_type.to_sym) if @section.property_type.present?
    else
      [:offer_type, :category].each do |m|
        with[m] = search_params[m].map{|e| e.to_i} if search_params[m].present?
      end
    end


    [:price].each do |m|
      if search_params["#{m}_from"].present?
        from = search_params["#{m}_from"].to_i
        to = search_params["#{m}_to"].present? ? search_params["#{m}_to"].to_i : 999999999
        from, to = to, from if to < from
        with["#{m}_from"] = from..to
        with["#{m}_to"] = from..to if search_params["#{m}_to"].present?
      end
    end

    [:not_for_agents, :mortgage].each do |m|
      with[m] = search_params[m] == '1' if search_params[m].present?
    end

    if search_params[:date_interval].present?
      date_from = (Date.parse(search_params[:date_interval].split('-').first.strip) - 1.day) rescue (DateTime.now - 1.day).to_date
      date_to = (Date.parse(search_params[:date_interval].split('-').last.strip) + 1.day) rescue (DateTime.now + 1.day).to_date
      date_from, date_to = date_to, date_from if date_to < date_from
      with[:updated_at] = date_from .. date_to
    end

    with[:location_ids] = @locations.map{|l| l.id}
    @search_result_ids = ThinkingSphinx.search_for_ids(search_params[:description].presence, options)
    @search_result_count = @search_result_ids.total_entries
    @pages = (@search_result_count.to_f / @limit.to_f).ceil
    @search_results = Advertisement.where(id: @search_result_ids).order('updated_at DESC')
  end

  def show
    @sections = Section.where(location_id: @adv.location_ids).
        where(offer_type: nil).
        where(category: nil)
    @photos = @adv.photos
    @today_counter, @all_days_counter = AdvertisementCounter.get_and_increase_count_for_adv(@adv.id)
    @grouped_allowed_attributes =  @adv.grouped_allowed_attributes
    @sorted_locations = @adv.locations.sort_by{|location| Location.locations_list.index(location.location_type.to_s)}

    with = {}
    conditions = {}
    options = {
        :conditions => conditions,
        :with => with,
        :order => 'updated_at DESC',
        :classes => [Advertisement]
    }
    options[:per_page] = 10

    [:offer_type, :category].each do |m|
      with[m] =  [@adv.attributes[m.to_s]]
    end
    [:price].each do |m|
      if @adv.price_from.present?
        from = @adv.price_from.to_i / 100 * 90
        to = @adv.price_to.present? ? (@adv.price_to.to_i / 100 * 110) : 999999999
        from, to = to, from if to < from
        with['price_from'] = from..to
        with['price_to'] = from..to if @adv.price_to.present?
      end
    end

    with['status_type'] = 0

    list = [
        @adv.locations.find_all{|n| n.location_type.to_sym == :district},
        @adv.locations.find_all{|n| n.location_type.to_sym == :city},
        @adv.locations.find_all{|n| n.location_type.to_sym== :non_admin_area},
        @adv.locations.find_all{|n| n.location_type.to_sym == :street},
        @adv.locations.find_all{|n| n.location_type.to_sym == :address}
    ].delete_if{|e| e.empty?}
    list.pop
    list.flatten!

    location_ids = list.map{|l| l.id}
    with[:location_ids] = location_ids
    @search_result_ids = ThinkingSphinx.search_for_ids('', options)
    @search_result_ids.delete_if{|result| result == @adv.id}
    @search_results = Advertisement.where(id: @search_result_ids)

    @near_sections = Section.where(location_id: location_ids).
        where(offer_type: Section.offer_types[@adv.offer_type]).
        where(category: Section.categories[@adv.category]).limit(10)
  end

  def edit
    @grouped_allowed_attributes = @adv.grouped_allowed_attributes
    load_location_state!(@adv.locations)
  end

  def new
    @adv = Advertisement.new
    @adv.offer_type = 0
    @adv.category = 0
    @adv.adv_type = :offer
    @adv.property_type = :residental
    @grouped_allowed_attributes = @adv.grouped_allowed_attributes
  end

  def create
    if can? :create_from_admin, Advertisement
      user = Phone.where(number: advertisement_params[:user_attributes][:phones_attributes].map{|_, e| Phone.normalize(e[:original])}).first.try :user
      if user.blank?
        @adv = Advertisement.new advertisement_params
        @adv.user.from_admin = true
      else
        @adv = user.advertisements.new advertisement_params
      end
    else
      @adv = current_user.advertisements.new advertisement_params
    end

    if @adv.valid?
      @adv.save and redirect_to advertisement_path(@adv)
    else
      load_location_state!
      @grouped_allowed_attributes = @adv.grouped_allowed_attributes
      @save_with_errors = true and render 'advertisements/new'
    end
  end

  def update
    if @adv.update_attributes(advertisement_params)
      redirect_to advertisement_path(@adv)
    else
      load_location_state!
      @grouped_allowed_attributes = @adv.grouped_allowed_attributes
      @save_with_errors = true and render 'advertisements/form'
    end
  end


  def get_locations
    if params[:parent_id].to_i != 0
      @location = Location.find(params[:parent_id])
      @locations = @location.children_locations
    else
      @locations = Location.where(location_type: 0)
    end
    @locations = @locations
    @locations = @locations.map do |l| { id: l.id,
                                         location_type: l.location_type,
                                         title: l.title,
                                         has_children: l.has_children?}
    end
    @title = @location.present? ? @location.title : 'Местоположение'
  end


  def get_attributes
    adv = Advertisement.new(category: params[:category].to_sym, adv_type: params[:adv_type].to_sym)
    @grouped_allowed_attributes = adv.grouped_allowed_attributes
  end

  def get_search_attributes
    adv = Advertisement.new(category: params[:category].to_sym, adv_type: params[:adv_type].to_sym)
    @grouped_allowed_attributes = adv.grouped_allowed_attributes
  end

  def check_phone
    @search_results = Advertisement
      .joins('INNER JOIN "phones" ON "advertisements"."user_id" = "phones"."user_id"')
      .where('phones.number' => params[:phones].split(',').map{|phone| Phone.normalize(phone)})
      .all
  end


  protected

  def load_location_state!(locations = nil)
    @locations = locations.is_a?(Array) && locations.size > 0 && locations.first.is_a?(Location) ? locations : Location.where(id: locations || params[:advertisement][:location_ids] || []).all
    @location_state  = @locations.map do |l|
      {
          id: l.id,
          location_id: l.location_id,
          location_type: l.location_type,
          title: l.title,
          has_children: l.has_children?
      }
    end.to_json
  end

  def parameterize(params)
    params.collect{|k,v| "#{k}=#{v}"}.join('&')
  end

  def set_location
    @location = params[:location] ? Location.search(conditions: { title: params[:location] }).first : nil
  end

  def find_adv
    @adv = Advertisement.find(params[:id])
  end

  def search_params
    params[:advertisement]
  end

  def advertisement_params
    params.require(:advertisement).permit(:category, :offer_type, :price_from, :landmark,
    :price_to, :not_for_agents, :district, :user_id,
    :floor_from, :space, :room_from, :comment, :private_comment, :phone, :adv_type, :latitude, :longitude,
    :property_type, :floor_cnt_from, :space_from, :floor_max, :mortgage, adv_type: [],
    offer_type: [], category: [], photo_ids: [], location_ids: [],
    user_attributes: [:name, :role, :password, :email, phones_attributes: [:id, :original, :_destroy]])
  end


end
