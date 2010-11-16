# coding: utf-8
class MenusController < ApplicationController
  attr_accessor :side
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js

  def index
    if params[:site_id]
      top_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'top' ORDER BY sites_menus.parent_id,sites_menus.position")
      left_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'left' ORDER BY sites_menus.parent_id,sites_menus.position")
      right_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'right' ORDER BY sites_menus.parent_id,sites_menus.position")
      bottom_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side ,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'bottom' ORDER BY sites_menus.parent_id,sites_menus.position")
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
      top_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'top' ORDER BY sites_menus.parent_id,sites_menus.position")
      left_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'left' ORDER BY sites_menus.parent_id,sites_menus.position")
      right_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'right' ORDER BY sites_menus.parent_id,sites_menus.position")
      bottom_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'bottom' ORDER BY sites_menus.parent_id,sites_menus.position")

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
  # Remove um item de menu
  def rm_menu
    @rm_menu = SitesMenu.find(params[:id])
    @rm_menu.destroy
    redirect_to :back, :notice => t("successfully_deleted")
  end
  # Altera a ordenação do menu
  def change_position
    @ch_pos_new = SitesMenu.find(params[:id])
    @ch_pos_old = SitesMenu.find(:first, :conditions => ["parent_id = ? and position = ?", @ch_pos_new.parent_id, params[:position]])
    if @ch_pos_old
      @ch_pos_new.position,@ch_pos_old.position = @ch_pos_old.position,@ch_pos_new.position
      @ch_pos_old.save!
      @ch_pos_new.update_attributes(params[:position])
      flash[:notice] = t"successfully_updated"
    else
      flash[:error] = t"error_updating_object"
    end
    redirect_back_or_default :controller => "menus", :action => "index", :side => @ch_pos_new.side
  end

  def to_site
    @side = params[:side] || 'left'
    site_menus_aux = Site.find(:first, :conditions => ['name = ?', params[:site_id]]).sites_menus
    @site_menus = []

    # remove os menus que já pertencem ao site
    @menus_linked = []
    site_menus_aux.each do |m|
      logger.debug "entra? " + m.side + ", " + @side
      if m.side.eql? @side
        logger.debug "entrou"
        @site_menus << m
        @menus_linked << Menu.find(m.menu.id)
      end
    end
    @menus = Menu.find(:all) - @menus_linked

  end

  def link_site
    @site = Site.find(:first, :conditions => ["name = ?", params[:site_id]])
    menus_id = params[:menus]
    
    unless menus_id.blank?
      menus_id.each do |menu_id|
        menu = Menu.find(menu_id)
        logger.debug "Adicionando o menu " + menu.title+ " no site " + @site.name
        @site.sites_menus << SitesMenu.new(:menu_id => menu.id, :side => params[:side])
      end
    end

    respond_to do |format|
      format.html {redirect_to :controller => 'menus', :action => 'to_site', :side => params[:side]}
    end
  end

  def unlink_site
    @site = Site.find(:first, :conditions => ["name = ?", params[:site_id]])
    menus_id = params[:sites_menus]
    
    unless menus_id.blank?
      menus_id.each do |menu_id|
        menu = SitesMenu.find(menu_id)
        unless @site.sites_menus.index(menu).nil?
          @site.sites_menus.delete menu
        else
        end
      end
    end

    respond_to do |format|
      format.html {redirect_to :controller => 'menus', :action => 'to_site'}
    end
  end

end
