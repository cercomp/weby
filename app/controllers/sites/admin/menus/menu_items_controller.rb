class Sites::Admin::Menus::MenuItemsController < ApplicationController
  include ActsToToggle
  
  before_filter :get_current_menu
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    redirect_to site_admin_menus_path(menu: @menu.id)
  end

  def show
    redirect_to site_admin_menus_path(menu: @menu.id)
  end

  def new
    set_parent_menu_item params[:parent_id]
    @menu_item = @menu.menu_items.new
  end

  def create
    @menu_item = @menu.menu_items.new(params[:menu_item])
    @menu_item.position = @menu.menu_items.maximum(:position, conditions: {parent_id: @menu_item.parent_id}).to_i + 1

    if @menu_item.save
      flash[:success] = t("successfully_created")
      record_activity("created_menu_item", @menu_item)
      redirect_to site_admin_menus_path(menu: @menu.id)
    else
      set_parent_menu_item params[:menu_item][:parent_id]
      render action: :new
    end
  end
  
  def edit
    @menu_item = @menu.menu_items.find(params[:id])
  end

  def update
    @menu_item = @menu.menu_items.find(params[:id])
    if @menu_item.update(params[:menu_item])
      flash[:success] = t("successfully_updated")
      record_activity("updated_menu_item", @menu_item)
      redirect_to site_admin_menus_path(menu: @menu.id)
    else
      render action: :edit
    end
  end

  def destroy
    @menu_item = @menu.menu_items.find(params[:id])
    if @menu_item.destroy
      record_activity("destroyed_menu_item", @menu_item)
      redirect_to :back, flash: {success: t("successfully_deleted")}
    else
      redirect_to :back, flash: {success: t("error_destroying_object")}
    end
  end

  # Altera a ordenação do menu
  def change_order
    @menu_item = @menu.menu_items.find(params[:id])
    @menu_item.update_positions(params[:menu_item])
    render nothing: true
  end

  # Altera o menu de um item de menu, e todos seus descendentes
  def change_menu
    @menu_item = @menu.menu_items.find(params[:id])
    @menu_item.position = MenuItem.maximum(:position, conditions: ["menu_id = :menu_id AND parent_id is NULL", menu_id: params[:new_menu_id]]).to_i + 1
    @menu_item.menu_id = params[:new_menu_id]
    @menu_item.parent_id = nil
    @menu_item.save!
    render nothing: true
  end

  private

  def get_current_menu
    @menu = current_site.menus.find(params[:menu_id])
  end

  def set_parent_menu_item(parent_id)
    @menu_item_parent = @menu.menu_items.find(parent_id) if parent_id
  end

  def resource
    get_resource_ivar || set_resource_ivar(@menu.menu_items.find(params[:id]))
  end
end
