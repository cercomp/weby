class Sites::Admin::MenusController < ApplicationController
  before_action :require_user
  before_action :check_authorization

  respond_to :html, :xml, :js
  def index
    @menus = current_site.menus
    @menu = params[:menu] ? @menus.select { |menu| menu.id == params[:menu].to_i }[0] : @menus.first
  end

  def show
    redirect_to site_admin_menus_path(menu: params[:id])
  end

  def new
    @menu = Menu.new
  end

  def create
    @menu = current_site.menus.new(menu_params)
    @menu.position = current_site.menus.maximum(:position).to_i + 1
    if @menu.save
      flash[:success] = t('successfully_created')
      record_activity('created_menu', @menu)
      redirect_to site_admin_menus_path(menu: @menu.id)
    else
      respond_with(:site_admin, @menu)
    end
  end

  def edit
    @menu = current_site.menus.find(params[:id])
  end

  def update
    @menu = current_site.menus.find(params[:id])
    if @menu.update(menu_params)
      flash[:success] = t('successfully_updated')
      record_activity('updated_menu', @menu)
      redirect_to site_admin_menus_path(menu: @menu.id)
    else
      respond_with(:site_admin, @menu)
    end
  end

  # Altera a ordenação do menu
  def change_order
    position = 0
    params[:menu].each do |menu_id|
      current_site.menus.find(menu_id).update_attribute(:position, position += 1)
    end
    head :ok
  end

  def destroy
    @menu = current_site.menus.find(params[:id])
    @menu.destroy
    flash[:success] = t('successfully_deleted')
    record_activity('destroyed_menu', @menu)
    redirect_to site_admin_menus_path
  end

  private

  def menu_params
    params.require(:menu).permit(:name)
  end
end
