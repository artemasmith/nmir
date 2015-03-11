class AbusesController < ApplicationController
  def create
    @adv = Advertisement.find(abuse_params[:advertisement_id])
    @abuse = Abuse.new abuse_params
    @abuse.user_id = current_user.try(:id)
    @abuse.advertisement_id = @adv.id
    @abuse.save!
  end


  def abuse_params
    params.require(:abuse).permit(:comment, :abuse_type, :advertisement_id)
  end
end
