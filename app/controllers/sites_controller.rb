class SitesController < ApplicationController
  layout :choose_layout, only: :show
  
  before_filter :require_user, :only => :admin
  
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= Setting.get(:per_page_default)

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
    flash[:warning] = (t"none_param", :param => t("page.one")) unless @sites
  end

  def show
    raise ActiveRecord::RecordNotFound unless @site
    params[:site_id] = @site.name
    params[:id] = @site.id
    params[:per_page] = nil
  end

  def admin
    render layout: 'application'
  end
  
  def edit
    @site = Site.find_by_name(params[:id])
    load_images_themes
    render layout: 'application'
  end

  def update
    @site = Site.find_by_name(params[:id])
    params[:site][:top_banner_id] ||= nil
    if @site.update_attributes(params[:site])
      flash[:notice] = t"successfully_updated"
      redirect_to admin_site_path(@site)
    else
      load_images_themes
      render :edit
    end
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def load_images_themes
    @images = @site.repositories.
      content_file(["image", "x-shockwave-flash"]).
      description_or_filename(params[:image_search]).
      page(params[:page]).
      per(params[:per_page])

    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/sites.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/user_sessions.html.erb")]).each do |file|
       @themes << file.split("/")[-1].split(".")[0]
     end
  end
end
