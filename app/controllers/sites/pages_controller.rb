class Sites::PagesController < ApplicationController
  include ActsToSort

  layout :choose_layout

  helper_method :sort_column
  before_action :check_current_site

  respond_to :html, :js, :json, :rss

  # GET /pages
  # GET /pages.json
  def index
    @pages = get_pages

    respond_with(:site, @page) do |format|
      format.rss { render layout: false, content_type: Mime::XML } # index.rss.builder
      format.atom { render layout: false, content_type: Mime::XML } # index.atom.builder
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = current_site.pages.find(params[:id])
    if request.path != site_page_path(@page)
      redirect_to site_page_path(@page), status: :moved_permanently
      return
    end

    respond_with(:site, @page)
  end

  private

  def tags
    params[:tags].split(',').map { |tag| tag.mb_chars.downcase.to_s }
  end

  def get_pages
    params[:direction] ||= 'desc'
    # Vai ao banco por linha para recuperar
    # tags e locales
    pages = current_site.pages.published.
      search(params[:search], params.fetch(:search_type, 1).to_i).
      order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(params[:per_page])

    pages
  end

  def sort_column
    params[:sort] || 'pages.id'
  end

  def check_current_site
    render_404 unless current_site
  end
end
