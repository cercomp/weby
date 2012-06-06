class Sites::Admin::MenusController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    @menus = @global_menus.map{|k,menu| menu} #@site.menus
    @menu = params[:menu] ? @global_menus[params[:menu].to_i] : @menus.first
  end

  def show
    @menu = @global_menus[params[:id].to_i] #@site.menus.find(params[:id])
    redirect_to site_admin_menus_path(:menu => @menu.id)
  end

  def new
    @menu = Menu.new
  end
  
  def create
    @menu = @site.menus.new(params[:menu])
    if @menu.save
      flash[:success] = t("successfully_created")
      redirect_to site_admin_menus_path(:menu => @menu.id)
    else
      respond_with(:site_admin, @menu)
    end
  end

  def edit
    @menu = @global_menus[params[:id].to_i] #@site.menus.find(params[:id])
  end

  def update
    @menu = @global_menus[params[:id].to_i] #@site.menus.find(params[:id])
    if @menu.update_attributes(params[:menu])
      flash[:success] = t("successfully_updated")
      redirect_to site_admin_menus_path(:menu => @menu.id)
    else
      respond_with(:site_admin, @menu)
    end
  end

  def destroy
    @menu = @global_menus[params[:id].to_i] #@site.menus.find(params[:id])
    @menu.destroy
    flash[:success] = t("successfully_deleted")
    redirect_to site_admin_menus_path
  end

end
