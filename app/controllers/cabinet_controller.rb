class CabinetController < ApplicationController
  before_action :authenticate_user!

  def index


    params[:advertisement] = {} if params[:advertisement].blank?
    params[:url] = true
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
    with[:user_id] = current_user.id

    [:expired].each do |m|
      if search_params[m].present? && search_params[m] == '1' && can?(:read_expired, Advertisement)
        with['status_type'] = AdvEnums::STATUSES.index(:expired)
      else
        with['status_type'] = AdvEnums::STATUSES.index(:active)
      end
    end

    @search_result_ids = ThinkingSphinx.search_for_ids('', options)
    @search_result_count = @search_result_ids.total_entries.to_i
    @search_results = Advertisement.where(id: @search_result_ids).order('updated_at DESC')
    @pages = (@search_result_count.to_f / @limit.to_f).ceil

  end

  def abuses
    @waiting_abuses = Abuse.where(user_id: @current_user.id).where(status: 0)
    @considered_abuses = Abuse.where(user_id: @current_user.id).where('status > 0')
    @abuses = @considered_abuses || []
    @abuses = @waiting_abuses if params[:status] == 'considered'
  end


  private

  def search_params
    params[:advertisement]
  end



end
