class Sites::PagesController < ApplicationController
  layout :choose_layout

  helper_method :sort_column
  before_action :check_current_site

  respond_to :html, :js, :json

  def index
    @pages = Page.get_pages current_site, params.merge(sort_column: sort_column, sort_direction: sort_direction)
    respond_with(@pages) do |format|
      format.json { render json: @pages, root: 'pages', meta: { total: @pages.total_count } }
    end
  end

  def show
    @page = current_site.pages.find(params[:id])
    raise ActiveRecord::RecordNotFound if !@page.publish && @page.user != current_user
    if request.path != site_page_path(@page)
      redirect_to site_page_path(@page), status: :moved_permanently
      return
    end
  end

  def redirect
    @news = Journal::News.find(params[:id])
    redirect_to @news.url.blank? ? news_url(@news, subdomain: @news.site) : @news.url
  end

  def sitemap
    @menus = current_site.active_skin.components.where(name: 'menu', publish: true).map do |component|
      Weby::Components.factory(component).menu
    end.compact.sort_by(&:position)
  end

  def frame
    cnt = open(params[:url]).read
    render html: cnt.html_safe
  end

  private

  def sort_column
    params[:sort] || 'pages.id'
  end

  def check_current_site
    render_404 unless current_site
  end
end
