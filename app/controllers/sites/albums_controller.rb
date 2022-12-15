class Sites::AlbumsController < ApplicationController
  include CheckSlug

  layout :choose_layout

  helper_method :sort_column
  before_action :check_current_site
  before_action :find_album, only: :show

  respond_to :html, :js, :json

  def index
    # desc_default_direction
    @albums = current_site.albums.order(created_at: :desc).page(params[:page]).per(10)
    respond_with(@albums) do |format|
      format.json { render json: @albums, root: 'albums', meta: { total: @albums.total_count } }
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
    @photos = @album.album_photos.page(params[:page]).per(50)
    if request.path != site_album_path(@album)
      redirect_to site_album_path(@album), status: :moved_permanently
      return
    end
  end

  private

  def sort_column
    params[:sort] || 'albums.id'
  end

  def check_current_site
    render_404 unless current_site
  end
end
