class PhotosController < ApplicationController
  layout false

  def index
    photos = Photo.where(id: params[:ids])
    json = []
    photos.each do |photo|
      json << photo.to_jq_upload
    end
    respond_to do |format|
      format.html { render :json => {files: json}.to_json }
      format.json { render :json => {files: json}.to_json }
    end
  end

  def create
    json = []
    photo_params.each do |advertisement_photo|
      photo = Photo.new
      photo.advertisement_photo = advertisement_photo
      if photo.save
        json << photo.to_jq_upload
      else
        json << { :error => "custom_failure "}
      end
    end
    respond_to do |format|
      format.html { render :json => {files: json}.to_json }
      format.json { render :json => {files: json}.to_json }
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    render :json => true
  end

  def photo_params
    params.require(:advertisement_photo)
  end


end
