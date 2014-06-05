class Sites::PagesController < ApplicationController
  layout :choose_layout
  include ActsToSort

  helper_method :sort_column
  before_filter :check_current_site

  respond_to :html, :js, :json, :rss

  # GET /pages
  # GET /pages.json
  def index
    @pages = get_pages

    respond_with(:site, @page) do |format|
      format.rss { render layout: false, content_type: Mime::XML } #index.rss.builder
      format.atom { render layout: false, content_type: Mime::XML } #index.atom.builder
    end
  end

  def events
    @pages = get_pages.send(params[:upcoming] ? :upcoming_events : params[:previous] ? :previous_events : :events)

    respond_with(current_site, @pages) do |format|
      format.any { render 'index' }
    end
  end

  def news
    @pages = get_pages.news
    respond_with(current_site, @pages) do |format|
      format.any { render 'index'}
    end
  end

  def tags
    params[:tags].split(',').map{ |tag| tag.mb_chars.downcase.to_s }
  end
  private :tags

  def get_pages
    params[:direction] ||= 'desc'
    # Vai ao banco por linha para recuperar
    # tags e locales
    pages = current_site.pages.available.
      search(params[:search], params.fetch(:search_type, 1).to_i).
      order(sort_column + " " + sort_direction).
      page(params[:page]).per(params[:per_page])

    pages = pages.tagged_with(tags, any: true) if params[:tags]
    pages
  end
  private :get_pages

  def sort_column
    params[:sort] || 'pages.id'
  end
  private :sort_column

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
  def check_current_site
    render_404 if not current_site
  end

end
