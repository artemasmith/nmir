class ImportUploaderController < ApplicationController
  def create
    res = FileUploader.save(params[:donrio])
    if res[:error].present?
      flash[:error] = res[:error]
      redirect_to rails_admin.import_donrio(model_name: :advertisement)
    else
      flash[:info] = 'Succesfully created file'
      ImporterWorker.perform_async(res[:file_path])
      redirect_to rails_admin.index_path(model_name: :advertisement)
    end
  end
end
