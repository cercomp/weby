class Sites::AlbumsController < ApplicationController
  include CheckSlug

  layout :choose_layout

  helper_method :sort_column
  before_action :check_current_site
  before_action :find_album, only: :show

  respond_to :html, :js, :json

  def index
    # desc_default_direction
    @albums = get_albums
    respond_with(@albums) do |format|
      format.json { render json: @albums, root: 'albums', meta: { total: @albums.total_count } }
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
    @photos = @album.album_photos.order(:position).page(params[:page]).per(50)
    if request.path != site_album_path(@album)
      redirect_to site_album_path(@album), status: :moved_permanently
      return
    end
  end

  private

  def sort_column
    params[:sort] || 'albums.id'
  end

  def get_albums
    params[:direction] ||= 'desc'

    current_site.albums.published.
      with_search(params[:search], params.fetch(:search_type, 1).to_i).
      order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(params[:per_page])
  end

  def check_current_site
    render_404 unless current_site
  end
end
