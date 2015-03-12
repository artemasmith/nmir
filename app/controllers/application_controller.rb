class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :configure_permitted_parameters, if: :devise_controller?




  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end
  
  private

  def set_current_user
    @current_user = current_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :email, :password, :password_confirmation, :role, {:phones_attributes => [:id, :original, :_destroy]})
    end

    #devise_parameter_sanitizer.for(:account_update).push(:role)
    #devise_parameter_sanitizer.for(:edit).push(:role)
    #devise_parameter_sanitizer.for(:edit){|u| u.permit(:name, :email, :password, :password_confirmation, :role, {:phones_attributes => [:id, :original, :_destroy]})}
    devise_parameter_sanitizer.for(:account_update){|u| u.permit(:name, :email, :current_password, :password, :password_confirmation, :role, {:phones_attributes => [:id, :original, :_destroy]})}

  end
end
