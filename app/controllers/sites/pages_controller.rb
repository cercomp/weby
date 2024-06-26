class Sites::PagesController < ApplicationController
  include CheckSlug

  layout :choose_layout

  helper_method :sort_column
  before_action :check_current_site
  before_action :find_page, only: :show

  respond_to :html, :js, :json

  def index
    desc_default_direction
    @pages = Page.get_pages current_site, params.merge(sort_column: sort_column, sort_direction: sort_direction)
    respond_with(@pages) do |format|
      format.json { render json: @pages, root: 'pages', meta: { total: @pages.total_count } }
    end
  end

  def show
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
    if params[:url].present? && params[:url].match(/^(http|ftp)/)
      begin
        uri = URI(params[:url])
        cnt = URI.open(uri).read
        render html: cnt.html_safe
      rescue => exception
        render plain: 'URL inválida'
      end
    else
      render plain: 'URL inválida'
    end
  end

  private

  def sort_column
    params[:sort] || 'pages.id'
  end

  def check_current_site
    render_404 unless current_site
  end
end
