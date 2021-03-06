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
        :classes => [Advertisement]
    }
    @limit = (params[:per_page].presence || cookies[:per_page].presence || 25).to_i

    cookies[:per_page] = params[:per_page] if params[:per_page].present? && params[:per_page].to_i > 0

    options[:page] = (params[:page] || 1).to_i
    options[:per_page] = @limit
    with[:user_id] = current_user.id

    [:expired].each do |m|
      if search_params[m].present? && search_params[m] == '1'
        with['status_type'] = AdvEnums::STATUSES.index(:expired)
      else
        with['status_type'] = AdvEnums::STATUSES.index(:active)
      end
    end

    [:order].each do |m|
      if search_params[m].present? && search_params[m] == '1' && can?(:order, Advertisement)
        options[m] = 'created_at DESC'
      else
        options[m] = 'updated_at DESC'
      end
    end

    @search_result_ids = ThinkingSphinx.search_for_ids('', options)
    @search_result_count = @search_result_ids.total_entries.to_i
    @search_results = Advertisement.where(id: @search_result_ids).order('updated_at DESC')
    @pages = (@search_result_count.to_f / @limit.to_f).ceil

  end

  def edit
  end

  def destroy
    user = User.find(params[:id].to_i)
    if user.present? && user.valid_password?(params[:password])
      user.destroy
      redirect_to root_path
    else
      flash.now[:error] = 'не могу удалить учетную запись: неправильный пароль'
      render 'cabinet/edit'
    end
  end


  private

  def search_params
    params[:advertisement]
  end



end
