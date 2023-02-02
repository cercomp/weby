class Sites::AlbumPhotosController < ApplicationController
  layout :choose_layout

  before_action :find_album, only: :show

  respond_to :html, :js, :json

  def show
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
    @album_photo = @album.album_photos.find(params[:id])
  end

end
