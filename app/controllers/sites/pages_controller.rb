class Sites::PagesController < ApplicationController
  include ActsToSort

  layout :choose_layout

  helper_method :sort_column
  before_action :check_current_site

  respond_to :html, :js, :json, :rss

  def index
    @pages = get_pages

    respond_with(:site, @pages) do |format|
      format.rss { render layout: false, content_type: Mime::XML } # index.rss.builder
      format.atom { render layout: false, content_type: Mime::XML } # index.atom.builder
    end
  end

  def show
    @page = current_site.pages.published.find(params[:id])
    if request.path != site_page_path(@page)
      redirect_to site_page_path(@page), status: :moved_permanently
      return
    end
  end

  def redirect
    @news = Journal::News.find(params[:id])
    redirect_to @news.url.blank? ? news_path(@news) : @news.url
  end

  private

  def get_pages
    params[:direction] ||= 'desc'

    pages = current_site.pages.published.
      search(params[:search], params.fetch(:search_type, 1).to_i).
      order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(params[:per_page])
  end

  def sort_column
    params[:sort] || 'pages.id'
  end

  def check_current_site
    render_404 unless current_site
  end
end
