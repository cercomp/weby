# encoding: UTF-8
class Admin::SitesController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_authorization, :except => [:show, :index]
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= current_settings[:per_page_default]

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
    flash[:warning] = (t"none_page") unless @sites
  end

  def new
    @site = Site.new
    load_themes
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      if @site.theme == 'this2'
        theme = ::Themes::This2.new(@site)
        theme.populate
      end

      redirect_to site_admin_components_url(subdomain: @site)
    else
      load_themes
      respond_with @site
    end
  end

  def edit
    @site = Site.find_by_name(params[:id])
    load_themes
  end

  def update
    @site = Site.find_by_name(params[:id])
    if @site.update_attributes(params[:site])
      flash[:success] = t"successfully_updated"
      redirect_to admin_sites_path
    else
      load_themes
      render :edit
    end
  end

  def destroy
    #@site = Site.find_by_name(params[:id])
    #@site.destroy
    #respond_with(:admin, @site)
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def load_themes
    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/weby-pages.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/weby-sessions.html.erb")]).each do |file|
       @themes << file.split("/")[-1].split(".")[0]
     end
  end
end
