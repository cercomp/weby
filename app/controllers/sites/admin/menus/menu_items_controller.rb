class Sites::Admin::Menus::MenuItemsController < ApplicationController
  before_action :get_current_menu
  before_action :require_user
  before_action :check_authorization

  include ActsToToggle

  respond_to :html, :xml, :js

  def index
    redirect_to site_admin_menus_path(menu: @menu.id)
  end

  def show
    redirect_to site_admin_menus_path(menu: @menu.id)
  end

  def new
    @menu_item = @menu.menu_items.new_or_clone(params[:copy_from], parent_id: params[:parent_id])
    @menu_item_parent = @menu_item.parent
  end

  def create
    @menu_item = @menu.menu_items.new(menu_item_params)
    @menu_item.position = @menu.menu_items.where(parent_id: @menu_item.parent_id).maximum(:position).to_i + 1

    if @menu_item.save
      flash[:success] = t('successfully_created')
      record_activity('created_menu_item', @menu_item)
      redirect_to site_admin_menus_path(menu: @menu.id)
    else
      @menu_item_parent = @menu_item.parent
      render action: :new
    end
  end

  def edit
    @menu_item = @menu.menu_items.find(params[:id])
  end

  def update
    @menu_item = @menu.menu_items.find(params[:id])
    if @menu_item.update(menu_item_params)
      flash[:success] = t('successfully_updated')
      record_activity('updated_menu_item', @menu_item)
      redirect_to site_admin_menus_path(menu: @menu.id)
    else
      render action: :edit
    end
  end

  def destroy
    @menu_item = @menu.menu_items.find(params[:id])
    message = {error: t('error_destroying_object')}
    if @menu_item.destroy
      record_activity('destroyed_menu_item', @menu_item)
      message = {success: t('successfully_deleted')}
    end
    redirect_back(flash: message, fallback_location: site_admin_menus_path(menu: @menu.id))
  end

  def destroy_many
    @menu.menu_items.where(id: params[:ids].split(',')).each do |menu_item|
      if menu_item.destroy
        record_activity('destroyed_menu_item', menu_item)
        flash[:success] = t('successfully_deleted')
      end
    end
    redirect_back(fallback_location: site_admin_menus_path(menu: @menu.id))
  end

  # Altera a ordenação do menu
  def change_order
    @menu_item = @menu.menu_items.find(params[:id])
    @menu_item.update_positions(params[:menu_item])
    head :ok
  end

  # Altera o menu de um item de menu, e todos seus descendentes
  def change_menu
    @menu_item = @menu.menu_items.find(params[:id])
    @menu_item.position = MenuItem.where('menu_id = ? AND parent_id is NULL', params[:new_menu_id]).maximum(:position).to_i + 1
    @menu_item.menu_id = params[:new_menu_id]
    @menu_item.parent_id = nil
    @menu_item.save!
    head :ok
  end

  private

  def get_current_menu
    @menu = current_site.menus.find(params[:menu_id])
  end

  def resource
    get_resource_ivar || set_resource_ivar(@menu.menu_items.find(params[:id]))
  end

  def menu_item_params
    params.require(:menu_item).permit(:url, :target_id, :parent_id, :target_type, :new_tab,
                                      :publish, :html_class, { i18ns_attributes: [:id, :locale_id, :title, :description] })
  end
end
