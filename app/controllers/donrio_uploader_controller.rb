class DonrioUploaderController < ApplicationController
  def create

    redirect_to rails_admin.index_path(model_name: :advertisement)
  end
end
