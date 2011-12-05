class SitesController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_authorization, :except => [:show, :index]
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= Setting.get(:per_page_default)

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
    unless @sites
      flash[:warning] = (t"none_param", :param => t("page.one"))
    end
  end

  def show
    if(@site)
      params[:site_id] = @site.name
      params[:id] = @site.id
      params[:per_page] = nil
    else
      catcher
    end
  end

  def new
    @site = Site.new
    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] - Dir[File.join(Rails.root + "app/views/layouts/portal.html.erb")]).each do |file|
      @themes << file.split("/")[-1].split(".")[0]
    end
  end

  def edit
    @repositories = Repository.search(params[:search], params[:page],["archive_content_type LIKE ?","image%"])
    @site = Site.find_by_name(params[:id])
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      redirect_to site_site_components_path(@site)
    else
      respond_with @site
    end
  end

  def update
    @site = Site.find_by_name(params[:id])
    if @site.update_attributes(params[:site])
      flash[:notice] = t"successfully_updated"
    end
    redirect_to edit_site_admin_path(@site, @site)
  end

  def destroy
    @site = Site.find_by_name(params[:id])
    @site.destroy
    respond_with(@site)
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end
