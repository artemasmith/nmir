class AdvertisementsController < ApplicationController
  before_action :overload_params
  before_action :find_adv, only: [:edit, :update, :destroy, :top]
  before_action :authorize_resource!, only: [:edit, :update, :destroy, :top]
  before_action :permitting, only: [:index]


  def index
    params.delete(:utf8)
    params.delete(:page) and redirect_to(root_path(params)) and return if params[:page] == '1'
    if params[:advertisement].present?
      deleted = false
      params[:advertisement].each_key do |e|
        if params[:advertisement][e].blank?
          params[:advertisement].delete(e)
          deleted = true
        end
      end
      if deleted
        params.delete(:advertisement) if params[:advertisement].blank?
        redirect_to(root_path(params))
        return
      end
    end


    #clear
    params[:advertisement] = {} if params[:advertisement].blank?



    if params[:url].blank?

      offer_type_section = false
      category_section = false
      location_section = false
      property_type_section = false

      if search_params[:offer_type].present? && search_params[:offer_type].size == 1
        offer_type = search_params[:offer_type].first
        offer_type_section = true
      end

      if search_params[:category].present? && search_params[:category].size == 1
        category = search_params[:category].first
        category_section = true
      elsif search_params[:category].present? && (AdvEnums::RESIDENTAL_CATEGORIES.map{|e| e.to_s}).sort == search_params[:category].sort
        property_type = AdvEnums::PROPERTY_TYPES.index(:residental)
        property_type_section = true
      elsif search_params[:category].present? && (AdvEnums::COMMERCE_CATEGORIES.map{|e| e.to_s}).to_a.sort == search_params[:category].sort
        property_type = AdvEnums::PROPERTY_TYPES.index(:commerce)
        property_type_section = true
      end

      load_location_state!

      child_location_ids = []
      @locations.each do |m|
        child_location_ids << m if @locations.find{|n| n.location_id == m.id}.blank?
      end

      if child_location_ids.size == 1
        location_id = child_location_ids.first
        location_section = true
      end

      if (location_section && offer_type_section && category_section) ||
          (location_section && offer_type_section && property_type_section) ||
          (offer_type_section && property_type_section) ||
          (location_section) ||
          (offer_type_section && category_section)
        @section = Section.where(offer_type: offer_type, category: category, location_id: location_id, property_type: property_type).first
      end

      if @section.present? && @section.url != '/'
        [:action, :controller].each { |m| params.delete(m) }
        [:offer_type, :category, :location_ids, :property_type].each { |m| params[:advertisement].delete(m) }
        params.delete :advertisement if params[:advertisement].empty?
        build_nested_query = Rack::Utils.build_nested_query(params)
        redirect_to "#{@section.url}#{build_nested_query.present? ? "?#{build_nested_query}" : ''}" and return
      end

      @root_section = @section.presence || Section.root

    else
      @root_section = @section = Section.where(url: "/#{params[:url]}").first
      if @root_section.blank?
        raise ActionController::RoutingError.new("Not Found #{params[:url]}")
      end
      load_location_state!(@section.present? && @section.location_id ? Location.parent_locations(Location.find(@section.location_id)) : nil)
    end


    with = {}
    conditions = {}
    options = {
        :conditions => conditions,
        :with => with,
        :order => 'updated_at DESC',
        :classes => [Advertisement]
    }

    @limit = (params[:per_page].presence || 25).to_i

    options[:page] = (params[:page] || 1).to_i
    options[:per_page] = @limit



    adv_types = []
    categories = []
    offer_types = []

    if @section.present? && @section.url != '/'
      [:offer_type, :category].each do |m|
        with[m] =  [@section.attributes[m.to_s]] if @section.attributes[m.to_s].present?
      end
      with[:property_type] =  AdvEnums::PROPERTY_TYPES.index(@section.property_type.to_sym) if @section.property_type.present?

      if @section.offer_type.present?
        adv_types = [Advertisement.adv_type(@section.offer_type)]
        offer_types = [@section.offer_type]
      end
      categories = [@section.category] if @section.category.present?
    else
      [:offer_type, :category].each do |m|
        with[m] = search_params[m].map{|e| e.to_i} if search_params[m].present?
      end

      if search_params[:offer_type].present?
        adv_types = search_params[:offer_type].map{|e| Advertisement.adv_type(AdvEnums::OFFER_TYPES[e.to_i]) }.uniq
        offer_types = search_params[:offer_type].map{|e| AdvEnums::OFFER_TYPES[e.to_i]}.uniq
      end

      categories = search_params[:category].map{|e| AdvEnums::CATEGORIES[e.to_i].to_s}.uniq if search_params[:category].present?
    end

    @search_attributes = Advertisement.grouped_allowed_search_attributes(adv_types, categories, offer_types)

    [:price, :floor, :floor_cnt].each do |m|
      if search_params["#{m}_from"].present? || search_params["#{m}_to"].present?
        from = search_params["#{m}_from"].to_i
        to = search_params["#{m}_to"].present? ? search_params["#{m}_to"].to_i : 999999999
        from, to = to, from if to < from
        with["#{m}_from"] = from..to
        with["#{m}_to"] = from..to if search_params["#{m}_to"].present?
      end
    end

    [:space, :outdoors_space].each do |m|
      if search_params["#{m}_from"].present? || search_params["#{m}_to"].present?
        from = search_params["#{m}_from"].to_f
        to = search_params["#{m}_to"].present? ? search_params["#{m}_to"].to_f : 999999999.0
        from, to = to, from if to < from
        with["#{m}_from"] = from..to
        with["#{m}_to"] = from..to if search_params["#{m}_to"].present?
      end
    end

    [:room].each do |m|
      if search_params["#{m}"].present?
        param = []
        if search_params["#{m}"]['3'] == '1'
          min = 4
          [3, 2, 1].each do |e|
            min = e if search_params["#{m}"][(e - 1).to_s] == '1'
          end
          param = (min..999999999)
        else
          [1, 2, 3].each do |e|
            param << e if search_params["#{m}"][(e - 1).to_s] == '1'
          end
        end

        with["#{m}_from"] = with["#{m}_to"] = param
      end
    end

    [:mortgage].each do |m|
      with[m] = search_params[m] == '1' if search_params[m].present?
    end

    if current_user && current_user.agent?
      with[:not_for_agents] = false
    end

    [:owner].each do |m|
      with[:user_role] = AdvEnums::USER_ROLES.index(:owner) if search_params[m].present? && search_params[m] == '1'
    end



    [:mortgage].each do |m|
      with[m] = search_params[m] == '1' if search_params[m].present?
    end

    [:expired].each do |m|
      if search_params[m].present? && search_params[m] == '1' && can?(:read_expired, Advertisement)
        with['status_type'] = AdvEnums::STATUSES.index(:expired)
      else
        with['status_type'] = AdvEnums::STATUSES.index(:active)
      end
    end

    if search_params[:date_interval].present?
      date_from = (Date.parse(search_params[:date_interval].split('-').first.strip) - 1.day) rescue (DateTime.now - 1.day).to_date
      date_to = (Date.parse(search_params[:date_interval].split('-').last.strip) + 1.day) rescue (DateTime.now + 1.day).to_date
      date_from, date_to = date_to, date_from if date_to < date_from
      with[:updated_at] = date_from .. date_to
    end

    with[:location_ids] = @locations.find_all { |l|  @locations.find{ |n| n.location_id == l.id}.blank? }.map{|l| l.id}
    @search_result_ids = ThinkingSphinx.search_for_ids(search_params[:description].presence, options)
    @search_result_count = @search_result_ids.total_entries.to_i
    @total_result_count = ThinkingSphinx.count('', {:classes => [Advertisement]}).to_i
    @bbtags = {
        'search_entries' => "#{@search_result_count} #{Russian.p(@search_result_count, 'объявление', 'объявления', 'объявлений')}",
        'total_entries' => "#{@total_result_count} #{Russian.p(@total_result_count, 'объявление', 'объявления', 'объявлений')}"
    }
    @pages = (@search_result_count.to_f / @limit.to_f).ceil
    @search_results = Advertisement.where(id: @search_result_ids).order('updated_at DESC')


    if @root_section.present?
      if @root_section.location_id.present?
        @hidden_sections = begin# Rails.cache.fetch("hidden_locations:#{@root_section.id}", expires_in: 15.minutes) do
          hidden_sections = Section.great_than_10
          hidden_sections = hidden_sections.where.not(id: @root_section.id)
          hidden_sections = hidden_sections.where(location_id: @root_section.location_id)
          if @root_section.offer_type.present? && @root_section.category.present?
            query = Section.where.not(category: Section.categories[@root_section.category]).where(property_type: Section.property_types.values)
            hidden_sections = hidden_sections.where(query.where_values.inject(:or))
          elsif @root_section.offer_type.present? && @root_section.property_type.present?
            hidden_sections = hidden_sections.where.not(offer_type: nil)
          end
          hidden_sections = hidden_sections.order('advertisements_count DESC')
          hidden_sections.to_a
        end
      end



      @hidden_location_sections = Rails.cache.fetch("hidden_location_sections:#{@root_section.id}", expires_in: 15.minutes) do

        parent_location = @locations.find{|location| location.id == @root_section.location_id}
        hidden_location_ids = []
        neighborhood_ids = []
        if @root_section.offer_type.present?
          neighborhood_ids << @root_section.location_id
          neighborhood_ids += @locations.map(&:id)
        else
          hidden_location_ids << @root_section.location_id
          neighborhood_ids += @locations.map(&:id)
          neighborhood_ids.delete(@root_section.location_id)
        end
        neighborhood_ids += Neighborhood.where(location_id: @root_section.location_id).map(&:neighbor_id)

        query = Section.where('locations.location_id' => hidden_location_ids).where('locations.id' => neighborhood_ids)
        hidden_location_sections = Section.great_than_10.child_for.where(query.where_values.inject(:or))
        hidden_location_sections = hidden_location_sections.where.not('locations.location_type' => [Location.location_types[:street], Location.location_types[:address]])
        hidden_location_sections = hidden_location_sections.where(offer_type: nil).where(category: nil).where(property_type: nil)
        hidden_location_sections = hidden_location_sections.order('advertisements_count DESC')
        hidden_location_sections.to_a
      end


      if @root_section.offer_type.present? && (@root_section.category.present? || @root_section.property_type.present?) && @root_section.location_id.present?
        @current_sections = begin #Rails.cache.fetch("current_sections:#{@root_section.id}", expires_in: 15.minutes) do
          parent_location = @locations.find{|location| location.id == @root_section.location_id}
          neighborhood_ids = []
          hidden_location_ids = []
          hidden_location_ids << parent_location.id

          neighborhood_ids += @locations.map(&:id)
          neighborhood_ids += Neighborhood.where(location_id: @root_section.location_id).map(&:neighbor_id)


          query = Section.where('locations.location_id' => hidden_location_ids).where('locations.id' => neighborhood_ids)
          current_sections = Section.great_than_10.where.not(id: @root_section.id).child_for.where(query.where_values.inject(:or))
          current_sections = current_sections.where(offer_type: Section.offer_types[@root_section.offer_type])
          current_sections = current_sections.where.not('locations.location_type' => [Location.location_types[:street], Location.location_types[:address]])
          if @root_section.category.present?
            current_sections = current_sections.where(category: Section.categories[@root_section.category])
          else
            current_sections = current_sections.where(property_type: Section.property_types[@root_section.property_type])
          end
          current_sections = current_sections.order('advertisements_count DESC')
          current_sections.to_a
        end
      end
    end

    if ((params[:page].to_i > 1) && (@search_results.blank?))
      raise ActionController::RoutingError.new('Not Found')
    end

    if (@section.present? && @section.url != '/' && (@search_results.blank?) && params[:advertisement].blank?)
      parent_location = @locations.find{|location| location.id == @root_section.location_id}
      section = @current_sections.find{|section| section.location_id == parent_location.location_id} if @current_sections.present?
      return redirect_to section.url if section.present?
    end

  end

  def show
    @adv = Advertisement.where(id: params[:id]).first
    if @adv.blank?
      deleted_adv = DeletedAdvertisement.where(advertisement_id: params[:id]).first
      if deleted_adv.present?
        section = Section.find(deleted_adv.section_id)
        return redirect_to section.url, status: 301
      end
      raise ActionController::RoutingError.new('Not Found Adv')
    end

    if @adv.expired? && !can?(:read, @adv)
      return redirect_to @adv.section.url
    end



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
    ].delete_if{|e| e.empty?}.flatten

    location_ids = list.map{|l| l.id}
    with[:location_ids] = location_ids
    @search_result_ids = ThinkingSphinx.search_for_ids('', options)
    @search_result_ids.delete_if{|result| result == @adv.id}
    @search_results = Advertisement.where(id: @search_result_ids).where.not(id: @adv.id)

    @near_sections = Section.where(location_id: location_ids).
        where(offer_type: Section.offer_types[@adv.offer_type]).
        where(category: Section.categories[@adv.category]).limit(10).to_a.sort_by{|s| location_ids.index(s.location_id)}
  end

  def edit
    @grouped_allowed_attributes = @adv.grouped_allowed_attributes
    load_location_state!(@adv.locations)
  end

  def new
    @adv = Advertisement.new
    clids = cookies[:location_ids].split('&') if cookies[:location_ids].present?
    load_location_state!(clids) if clids.present?
  end

  def create
    if current_user.present?
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
    else
      @adv = Advertisement.new advertisement_params
    end
    if @adv.valid?
      @adv.save
      cookies[:location_ids] = advertisement_params[:location_ids]
      sign_in @adv.user if current_user.blank?
      redirect_to "#{advertisement_path(@adv)}-#{@adv.url}"
    else
      load_location_state!
      @grouped_allowed_attributes = @adv.grouped_allowed_attributes
      @save_with_errors = true and render 'advertisements/new'
    end
  end

  def update
    if @adv.update_attributes(advertisement_params)
      redirect_to "#{advertisement_path(@adv)}-#{@adv.url}"
    else
      load_location_state!
      @grouped_allowed_attributes = @adv.grouped_allowed_attributes
      @save_with_errors = true and render 'advertisements/form'
    end
  end


  def get_locations
    @location = Location.find(params[:parent_id]) if params[:parent_id].to_i != 0
    if params[:editable] == 'false'
      @locations = Rails.cache.fetch("get_locations:#{params[:offer_types]}:#{params[:categories]}:#{params[:parent_id]}", expires_in: 15.minutes) do
        get_locations_yield
      end
    else
      @locations = get_locations_yield
    end
  end

  def top
    @adv.updated_at = DateTime.now
    @adv.status_type = :active
    @adv.save
  end


  def get_attributes
    adv = Advertisement.new(category: params[:category].to_sym, offer_type: params[:offer_type].to_sym)
    @grouped_allowed_attributes = adv.grouped_allowed_attributes
  end

  def get_search_attributes
    offer_types = params[:offer_types].to_s.split(',').map{|e| AdvEnums::OFFER_TYPES[e.to_i]}.uniq
    adv_types = params[:offer_types].to_s.split(',').map{|e| Advertisement.adv_type(AdvEnums::OFFER_TYPES[e.to_i])}.uniq
    categories = params[:categories].to_s.split(',').map{|e| AdvEnums::CATEGORIES[e.to_i].to_s}.uniq

    @search_attributes = Advertisement.grouped_allowed_search_attributes(adv_types, categories, offer_types)
  end

  def check_phone
    @search_results = Advertisement
                          .joins('INNER JOIN "phones" ON "advertisements"."user_id" = "phones"."user_id"')
                          .where('phones.number' => params[:phones].split(',').map{|phone| Phone.normalize(phone)})
                          .all
  end

  def destroy
    unless request.xhr?
      location_id = @adv.locations.sort_by{|location| Location.locations_list.index(location.location_type.to_s)}.last.try(:id)
      section = Section.where(location_id: location_id).
          where(offer_type: Section.offer_types[@adv.offer_type]).
          where(category: Section.categories[@adv.category]).first
      redirect_to((section.present? ? section.url : root_path), notice: 'Объявление успешно удалено')
    end
    @adv.destroy
  end

  protected

  def load_location_state!(locations = nil)
    @locations =
        if locations.is_a?(Array) && locations.size > 0 && locations.first.is_a?(Location)
          locations
        else
          ids = locations || params[:advertisement][:location_ids] || []
          ids.present? ? Location.where(id: ids).all : []
        end
    @location_state  = @locations.map do |l|
      {
          id: l.id,
          location_id: l.location_id,
          location_type: l.location_type,
          title: l.title,
          has_children: l.has_children? || (l.street? && params[:action] == 'edit')
      }
    end.to_json
  end

  def parameterize(params)
    params.collect{|k,v| "#{k}=#{v}"}.join('&')
  end


  def find_adv
    @adv = Advertisement.find(params[:id])
  end

  def authorize_resource!
    raise CanCan::AccessDenied unless can?(:update, @adv) if [:edit, :update, :top].include?(params[:action].to_sym)
    raise CanCan::AccessDenied unless can?(:destroy, @adv) if [:destroy].include?(params[:action].to_sym)
  end

  def search_params
    params[:advertisement]
  end

  def permitting
    params.permit(
                   :utm_source,
                   :utm_medium,
                   :utm_campaign,
                   :utm_term,
                   :utf8,
                   :page,
                   :url,
                   :per_page,
                   :advertisement => [
                   :description,
                   :date_interval,
                   :owner,
                   :category,
                   :offer_type,
                   :property_type,
                   :landmark,
                   :comment,
                   :price_from,
                   :price_to,
                   :not_for_agents,
                   :district,
                   :floor_from,
                   :floor_to,
                   :floor_cnt_from,
                   :floor_cnt_to,
                   :space_from,
                   :space_to,
                   :outdoors_space_from,
                   :outdoors_space_to,
                   :mortgage,
                   :adv_type,
                   offer_type: [],
                   category: [],
                   photo_ids: [],
                   location_ids: [],
                   room: {'0' => {},
                          '1' => {},
                          '2' => {},
                          '3' => {},
                          '4' => {}
                   }])
  end

  def advertisement_params
    params.require(:advertisement).permit(:category, :offer_type, :property_type,
                                          :landmark, :comment,
                                          :price_from, :price_to,
                                          :not_for_agents,
                                          :district,
                                          :user_id,
                                          :floor_from, :floor_to,
                                          :floor_cnt_from, :floor_cnt_to,
                                          :space_from, :space_to,
                                          :outdoors_space_from, :outdoors_space_to,
                                          :room_from, :room_to,


                                          :phone, :adv_type,
                                          :latitude, :longitude, :zoom,

                                          :mortgage,
                                          adv_type: [], offer_type: [], category: [], photo_ids: [], location_ids: [],
                                          user_attributes: [:name, :role, :password, :password_confirmation, :email, phones_attributes: [:id, :original, :_destroy]])
  end

  def overload_params
    if params[:advertisement].present?
      if params[:advertisement][:price_from].present?
        params[:advertisement][:price_from] = params[:advertisement][:price_from].to_s.gsub(' ', '')
      end

      if params[:advertisement][:price_to].present?
        params[:advertisement][:price_to] = params[:advertisement][:price_to].to_s.gsub(' ', '')
      end
    end
  end

  def get_locations_yield
    if params[:editable] == 'false'
      offer_types = params[:offer_types].to_s.split(',').map{|e| e.to_i}.uniq
      categories = params[:categories].to_s.split(',').map{|e| e.to_i}.uniq
    end

    if @location.present?
      if @location.city?
        locations = @location.children_locations(:non_admin_area)
      else
        locations = @location.children_locations
      end
    else
      locations = Location.where(location_type: 0)
    end

    if params[:editable] == 'false'
      sections =  Section.where(location_id: locations.map(&:id))
      sections = Section.where(offer_type: offer_types) if offer_types.present?
      sections = sections.where(category: categories) if categories.present?
      sections = sections.where('advertisements_count > 0').to_a
    end

    locations = locations.map do |l|
      { id: l.id, location_type: l.location_type, title: l.title, has_children: (l.has_children?)  }
    end

    locations = locations.delete_if{|l| sections.find{|s| s.location_id == l[:id]}.blank?} unless sections.nil?

    locations.group_by{|l| l[:location_type]}
  end


end
