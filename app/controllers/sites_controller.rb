class SitesController < ApplicationController
  layout :choose_layout, only: :show
  layout 'weby_pages', only: :index
  
  before_filter :require_user, only: [:admin, :edit, :update]
  before_filter :check_authorization, only: [:edit, :update]

  respond_to :html, :xml, :js, :txt

  helper_method :sort_column

  #### FRONT-END

  def index
    params[:per_page] ||= current_settings[:per_page_default]

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
    flash[:warning] = (t"none_page") unless @sites
  end

  def show
    raise ActiveRecord::RecordNotFound unless @site
    params[:site_id] = @site.name
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
    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/sites.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/session.html.erb")]).each do |file|
       @themes << file.split("/")[-1].split(".")[0]
     end
  end
end
