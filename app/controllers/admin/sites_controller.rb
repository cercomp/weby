# encoding: UTF-8
class Admin::SitesController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_authorization, :except => [:show, :index]
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= current_settings.per_page_default

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
  end

  def new
    @site = Site.new
    @site.theme = 'this2' #default theme, TODO fazer isso ser configurável caso os temas sejam desvinculados do core
    load_themes
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      theme = ::Weby::Theme.new @site
      theme.populate
      
      redirect_to site_admin_components_url(subdomain: @site)
    else
      load_themes
      respond_with @site
    end
  end

  def edit
    @site = Site.find(params[:id])
    load_themes
  end

  def update
    @site = Site.find(params[:id])
    if @site.update_attributes(params[:site])
      flash[:success] = t"successfully_updated"
      redirect_to edit_admin_site_path(@site.id)
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
    @themes = Weby::Themes.all
  end
end
