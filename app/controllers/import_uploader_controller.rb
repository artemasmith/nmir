class ImportUploaderController < ApplicationController
  def create
    raise 'invalid type of file' unless %w(donrio adresat).include?(params[:type])
    res = FileUploader.save(params[:file])
    if res[:error].present?
      flash[:error] = res[:error]
      case params[:type]
        when 'donrio' then redirect_to rails_admin.import_donrio(model_name: :advertisement)
        when 'adresat' then redirect_to rails_admin.import_adresat(model_name: :advertisement)
      end
    else
      flash[:info] = 'Succesfully created file'
      ImporterWorker.perform_async(res[:file_path], current_user.email, params[:type])
      redirect_to rails_admin.index_path(model_name: :advertisement)
    end
  end
end
