class PhotosController < ApplicationController
  before_filter :load_resouces

  def create
    @photo = Photo.new(photo_params)

    if @photo.save
      respond_to do |format|
        format.html { render :json => [@photo.to_jq_upload].to_json, :content_type => 'text/html', :layout => false }
        format.json { render :json => {files: [@photo.to_jq_upload]}.to_json }
      end
    else
      render :json => [{ :error => "custom_failure "}], :status => 304
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy

    render :json => true
  end

  private

  def load_resouces
    @adv = Advertisement.find(params['advertisement_id'])
  end

end
