class MenusController < ApplicationController
  layout :choose_layout

  before_filter :require_user, :except => [:index, :show]
  before_filter :check_authorization, :except => [:index, :show]

  respond_to :html, :xml, :js

  def index
    @menus = Menu.all
    respond_with(@menus)
  end

  def show
    @menu = Menu.find(params[:id])
    respond_with(@menu)
  end

  def new 
    @menu_parent = SitesMenu.find(params[:parent_id]) if params[:parent_id]

    @menu = Menu.new
    @menu.sites_menus.build
    respond_with(@menu)
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def create
    @menu = Menu.new(params[:menu])
    @menu.save
    if @menu.save 
      flash[:notice] =  t("successfully_created")
    else
      flash[:error] = @menu.errors.full_messages
    end
    redirect_back_or_default :site_id => @menu.sites[0].name, :controller => "menus", :action => "index", :side => @menu.sites_menus[0].side
  end

  def update
    @menu = Menu.find(params[:id])
    @menu.update_attributes(params[:menu])
    redirect_back_or_default :site_id => @menu.sites[0].name, :controller => "menus", :action => "index", :side => @menu.sites_menus[0].side
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
    @ch_pos_old = SitesMenu.find(:first, :conditions => ["parent_id = ? and side = ? and position = ?", @ch_pos_new.parent_id, @ch_pos_new.side, params[:position]])
    if @ch_pos_old
      @ch_pos_new.position,@ch_pos_old.position = @ch_pos_old.position,@ch_pos_new.position
      @ch_pos_new.save
      @ch_pos_old.save
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
