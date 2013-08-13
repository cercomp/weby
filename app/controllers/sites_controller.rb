class SitesController < ApplicationController
  layout :choose_layout, only: :show
  
  before_filter :require_user, only: [:admin, :edit, :update]
  before_filter :check_authorization, only: [:edit, :update]

  respond_to :html, :xml, :js

  helper_method :sort_column

  #### FRONT-END

  def index
    params[:page] ||= 1

    #TODO Pesquisar pelas notícias
    @sites = Site.ordered_by_front_pages(params[:search]).
    page(params[:page]).
    per(52)

    @nexturl = sites_path(page: params[:page].to_i+1, search: params[:search])
    @my_sites = current_user ? current_user.sites : []

    # FIX ME - SORT SHOULD BE DONE IN MODEL ( SELECT DISTINC PREVENTS IT)
    #@pages = Page.front.published.available.clipping.search(params[:search], 1).sort{| a,b| b.created_at <=> a.created_at}

    if request.xhr?
      render partial: 'list', layout: false
    else
      render layout: 'weby_pages'
    end
  end

  def show
    raise ActiveRecord::RecordNotFound unless @site
    params[:id] = @site.id
    params[:per_page] = nil
  end
  
  def robots
    robots_file = Rails.root.join("public", "uploads", current_site.id.to_s, "original_robots.txt") if current_site

    #render file: (robots_file && FileTest.exist?(robots_file) ?
    #  robots_file : Rails.root.join("public","default_robots.txt")), :layout => false, :content_type => "text/plain"
    render text: File.read(robots_file && FileTest.exist?(robots_file) ?
      robots_file : Rails.root.join("public","default_robots.txt")), :layout => false, :content_type => "text/plain"

  end

  def about
    render partial: 'layouts/shared/about'
  end

  #### BACK-END

  def admin
    render layout: "application"
  end

  def edit
    @site = current_site
    load_themes
    @sites = @site.subsites.
      except(:order).
      order(:title).
      page(1).
      per(100)

    render layout: "application"
  end

  def update
    @site = current_site
    params[:site][:top_banner_id] ||= nil
    if @site.update_attributes(params[:site])
      flash[:success] = t("successfully_updated")
      redirect_to edit_site_admin_url(subdomain: @site)
    else
      load_themes
      render :edit, layout: "application"
    end
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def load_themes
    @themes = Weby::Themes.all
  end
end
