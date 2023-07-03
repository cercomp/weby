class Sites::AlbumPhotosController < ApplicationController
  layout :choose_layout

  before_action :find_album, only: [:show, :download]

  respond_to :html, :js, :json

  def show
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
    @album_photo = @album.album_photos.find(params[:id])
  end

  def download
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
    @album_photo = @album.album_photos.find(params[:id])
    redirect_to @album_photo.image.url(:o)
  end

end
