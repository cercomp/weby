class MenusController < ApplicationController
  layout :choose_layout

  before_filter :require_user, :except => [:index, :show]
  before_filter :check_authorization, :except => [:index, :show]

  respond_to :html, :xml, :js

  def index
    params[:side] ||= 'left'
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
    if @menu.save 
      flash[:notice] = t("successfully_created")
      redirect_back_or_default site_menus_path(@site, :side => @menu.sites_menus[0].side)
    else
      respond_with(@site, @menu)
    end
  end

  def update
    @menu = Menu.find(params[:id])
    if @menu.update_attributes(params[:menu])
      flash[:notice] = t("successfully_updated")
      redirect_back_or_default site_menus_path(@site, :side => @menu.sites_menus[0].side)
    else
      respond_with(@site, @menu)
    end 
  end

  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy
    respond_with(@menu)
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
    elsif params[:position]
      @ch_pos_new.position = params[:position]
      @ch_pos_new.save
    else
      flash[:error] = t"error_updating_object"
    end
    redirect_back_or_default site_menus_path(@site, :side => @ch_pos_new.side)
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
  # Remove iten(s) do menu
  def rm_menu
    @rm_menu = SitesMenu.find(params[:id])
    if @rm_menu  
        ary_for_del = del_deep(@menus_all[@rm_menu.side], @rm_menu.id)
        ary_for_del.each do |item|
          item.destroy
      end
    end
    @rm_menu.destroy
    redirect_to :back, :notice => t("successfully_deleted")
  end

  private
  def del_deep(obj, pos)
    res ||= []
    unless obj[pos].nil?
      obj[pos].each do |child|
        del_deep_entry(obj, child, res)
      end
      res.flatten
    end
    res
  end
  def del_deep_entry(obj, child, res)
    res << child
    if obj[child.id].class.to_s == "Array"
      obj[child.id].each do |sub_child|
        del_deep_entry(obj, sub_child, res)
      end
    end
    res
  end
end
