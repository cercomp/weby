class MenusController < ApplicationController
  require 'pp'
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization, :except => [:new, :create, :edit, :update]

  respond_to :html, :xml, :js

  def index
    if params[:site_id]
      top_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'top'")
      left_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'left'")
      right_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'right'")
      bottom_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'bottom'")
    else
      top_untreated = "" 
      left_untreated = ""
      right_untreated = ""
      bottom_untreated = ""
    end

    @left = menu_treat(left_untreated) 
    @right = menu_treat(right_untreated) 
    @top = menu_treat(top_untreated) 
    @bottom = menu_treat(bottom_untreated) 
  end

  def show
    @menu = Menu.find(params[:id])
    respond_with(@menu)
  end

  def new
    @menu = Menu.new
    @menu.sites_menus.build
    respond_with(@menu)
  end

  def edit
      top_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'top'")
      left_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'left'")
      right_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'right'")
      bottom_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'bottom'")

    @left = menu_treat(left_untreated) 
    @right = menu_treat(right_untreated) 
    @top = menu_treat(top_untreated) 
    @bottom = menu_treat(bottom_untreated) 
    @menu = Menu.find(params[:id])
  end

  def create
    @menu = Menu.new(params[:menu])
    @menu.save
    redirect_to :back, :notice =>  t("succesfully_created")
 
  end

  def update
    @menu = Menu.find(params[:id])
    @menu.update_attributes(params[:menu])
    respond_with(@menu)
  end

  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy
    respond_with(@menu)
  end
  
  def rm_menu
    @rm_menu = SitesMenu.find(params[:id])
    @rm_menu.destroy
    redirect_to :back, :notice => t("successfully_deleted")
  end
end
