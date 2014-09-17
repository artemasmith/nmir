class Api::AdvertisementsController < ApplicationController
  before_action :authenticate_user!
  def show
    @advertisement= Advertisement.find(params[:id])
    render js: { name: @advertisement.name, phone: @advertisement.phone }.to_json
  end

  def check_phone
    if current_user.admin?
      @users = []
      @user = ''
      @advertisements = []
      params[:phones].split(',').each do |phone|
        phonei = Phone.find_by_original(phone)
        if !phonei.blank? && !phonei.user.blank?
          @users << phonei.user
          #CHECK THIS SOLUTION!!!!!!!!
          @user = phonei.user.id
        end
      end
      @user = User.where('email = ?', params[:email]).first if !params[:email].blank?
      @users.each { |u| u.advertisements.each{ |a| @advertisements << a } }

      render  'advertisements/check_phone.js.erb'

    end
  end

end