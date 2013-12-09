class Sites::Admin::MenusController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    if params[:deleted] == 'true'
      @menus = Menu.unscoped.where(deleted: true, site_id: current_site.id)
      @menu = params[:menu] ? @menus.select{|menu| menu.id == params[:menu].to_i}[0] : @menus.first
      render "trash"
    else
      @menus = current_site.menus
      @menu = params[:menu] ? @menus.select{|menu| menu.id == params[:menu].to_i}[0] : @menus.first
    end
  end

  def show
    redirect_to site_admin_menus_path(:menu => params[:id])
  end

  def new
    @menu = Menu.new
  end
  
  def create
    @menu = current_site.menus.new(params[:menu])
    if @menu.save
      flash[:success] = t("successfully_created")
      redirect_to site_admin_menus_path(:menu => @menu.id)
    else
      respond_with(:site_admin, @menu)
    end
  end

  def edit
    @menu = current_site.menus.find(params[:id])
  end

  def update
    @menu = current_site.menus.find(params[:id])
    if @menu.update_attributes(params[:menu])
      flash[:success] = t("successfully_updated")
      redirect_to site_admin_menus_path(:menu => @menu.id)
    else
      respond_with(:site_admin, @menu)
    end
  end

  def destroy
    @menu = current_site.menus.unscoped.find(params[:id])
    @menu.destroy
    flash[:success] = t("successfully_deleted")
    redirect_to :back
  end

  def remove
    @menu = current_site.menus.find(params[:id])
    @menu.update_attribute(:deleted, true)
    MenuItem.update_all('deleted = true', menu_id: @menu.id)

    redirect_to :back
  end

  def recover
    @menu = current_site.menus.unscoped.find(params[:id])
    @menu.update_attribute(:deleted, false)
    MenuItem.update_all('deleted = false', menu_id: @menu.id)

    redirect_to :back
  end

end
