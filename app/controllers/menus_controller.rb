class MenusController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization, :except => [:new, :create, :edit, :update]

  respond_to :html, :xml, :js

  def index
    if params[:site_id]
      @top = "" 
      @left = @site.sites_menus
      @right = ""
    else
      @top = "" 
      @left = ""
      @right = ""
    end
  end

  def show
    @menu = Menu.find(params[:id])
    respond_with(@menu)
  end

  def new
    @menu = Menu.new
    respond_with(@menu)
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def create
    @menu = Menu.new(params[:menu])
    @menu.save
    respond_with(@menu)
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
end
