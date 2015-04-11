class AbusesController < ApplicationController
  def create
    @adv = Advertisement.find(abuse_params[:advertisement_id])
    @abuse = @adv.abuses.new abuse_params
    @abuse.user_id = current_user.try(:id)
    @abuse.save!
  end

  def accept
    abuse = Abuse.find(params[:id].to_i)
    if abuse.present? && abuse.update(status: 1)
      flash[:notice] = 'updated abuse'
    else
      flash[:alert] = 'could not update abuse'
    end
    redirect_to rails_admin.abuses_path(model_name: :abuse)
  end

  def decline
    abuse = Abuse.find(params[:id].to_i)
    if abuse.present? && abuse.update(status: 2)
      flash[:notice] = 'updated abuse'
    else
      flash[:alert] = 'could not update abuse'
    end
    redirect_to rails_admin.abuses_path(model_name: :abuse)
  end

  private

  def abuse_params
    params.require(:abuse).permit(:comment, :abuse_type, :advertisement_id).tap do |w|
      w[:abuse_type] = w[:abuse_type].to_i if w[:abuse_type].present?
    end
  end
end
