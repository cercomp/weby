class Sites::AlbumsController < ApplicationController
  include CheckSlug

  layout :choose_layout

  helper_method :sort_column
  before_action :check_current_site
  before_action :find_album, only: :show

  respond_to :html, :js, :json

  def index
    # desc_default_direction
    # @pages = Page.get_pages current_site, params.merge(sort_column: sort_column, sort_direction: sort_direction)
    # respond_with(@pages) do |format|
    #   format.json { render json: @pages, root: 'pages', meta: { total: @pages.total_count } }
    # end
  end

  def show
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
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
