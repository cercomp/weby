class MenusController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    @menus = @site.menus
    @menu = params[:menu] ? @site.menus.find(params[:menu]) : @site.menus.first
  end

  def show
    @menu = @site.menus.find(params[:id])
    @menus = [@menu]
    render action: :index
  end

  def new
    @menu = Menu.new
  end

  def edit
    @menu = @site.menus.find(params[:id])
  end

  def create
    @menu = @site.menus.new(params[:menu])
    if @menu.save
      flash[:notice] = t("successfully_created")
      redirect_back_or_default site_menus_path(@site, :menu => @menu.id)
    else
      respond_with(@site, @menu)
    end
  end

  def update
    @menu = @site.menus.find(params[:id])
    if @menu.update_attributes(params[:menu])
      flash[:notice] = t("successfully_updated")
      redirect_back_or_default site_menus_path(@site, :menu => @menu.id)
    else
      respond_with(@site, @menu)
    end
  end

  def destroy
    @menu = @site.menus.find(params[:id])
    @menu.destroy
    flash[:notice] = t("successfully_deleted")
    redirect_back_or_default site_menus_path(@site)
  end

end