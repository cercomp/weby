class Sites::Admin::Menus::MenuItemsController < ApplicationController
  before_filter :get_current_menu
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    redirect_to site_admin_menus_path(:menu => @menu.id)
  end

  def new
    get_parent_menu_item params[:parent_id]
    @menu_item = @menu.menu_items.new
  end

  def create
    @menu_item = @menu.menu_items.new(params[:menu_item])
    @menu_item.position = @menu.menu_items.maximum('position', :conditions=> {parent_id: @menu_item.parent_id}).to_i + 1

    if @menu_item.save
      flash[:success] = t("successfully_created")
      redirect_to site_admin_menus_path(:menu => @menu.id) 
    else
      get_parent_menu_item params[:menu_item][:parent_id]
      render action: :new
    end
  end

  def edit
    @menu_item = @menu.menu_items.find(params[:id])
  end

  def update
    @menu_item = @menu.menu_items.find(params[:id])
    if @menu_item.update_attributes(params[:menu_item])
      flash[:success] = t("successfully_updated")
      redirect_to site_admin_menus_path(:menu => @menu.id)
    else
      render action: :edit
    end
  end

  def destroy
    @menu_item = @menu.menu_items.find(params[:id])
    update_position_for_remove(@menu_item)
    @menu_item.destroy
    redirect_to :back, flash: {success: t("successfully_deleted")}
  end

  # Altera a ordenação do menu
  def change_order
    @ch_pos = @menu.menu_items.find(params[:id])

    update_position_for_remove(@ch_pos)

    @ch_pos.parent_id = params[:parent_id]
    @ch_pos.position = params[:position]

    idx = 1
    items = @menu.items_by_parent;
    items[@ch_pos.parent_id].each { |smenu|
      if(smenu.id != @ch_pos.id)
        if(idx == @ch_pos.position)
          idx += 1
        end
        smenu.update_attribute(:position, idx)
        idx += 1
      end
    } if items[@ch_pos.parent_id]

    @ch_pos.save
    render :nothing => true
  end

  # Altera o menu de um item de menu, e todos seus descendentes
  def change_menu
    @ch_menu = @menu.menu_items.find(params[:id])
    change_menu_deep(@ch_menu, params[:new_menu_id])

    render :nothing => true
  end

  private
  def get_current_menu
    @menu = current_site.menus.find(params[:menu_id])
  end

  def get_parent_menu_item(parent_id)
    @menu_item_parent = @menu.menu_items.find(parent_id) if parent_id
  end

  def items_deep(menu, menuitem)
    res ||= []
    menuitems = menu.items_by_parent
    if menuitems[menuitem.id]
      menuitems[menuitem.id].each do |child|
        items_deep_entry(menuitems, child, res)
      end
    end
    res.flatten
  end

  def items_deep_entry(menuitems, child, res)
    res << child
    if menuitems[child.id].class.to_s == "Array"
      menuitems[child.id].each do |sub_child|
        items_deep_entry(menuitems, sub_child, res)
      end
    end
    res
  end

  #Atualiza a position de todos os itens menos o do obj, assumindo que ele irá para outro parent_id
  def update_position_for_remove(obj)
    idx = 1
    items = @menu.items_by_parent;
    items[obj.parent_id].each { |menuis|
      if menuis.id != obj.id
        menuis.update_attribute(:position, idx)
        idx += 1
      end
    } if items[obj.parent_id]
  end

  #obj tem que ter o atributo menu_id, seu antigo menu_id, seu antigo parent_id e antiga position
  def change_menu_deep(obj, new_menu_id)
    if (obj && obj.menu_id!=new_menu_id)
      ary_for_up = items_deep(@menu, obj)
      ary_for_up.each do |item|
        item.menu_id = new_menu_id
        item.save
      end
      update_position_for_remove(obj)
      parent_id = nil
      @new_menu = current_site.menus.find new_menu_id
      position = @new_menu.menu_items.maximum('position', :conditions=> [' parent_id = ? AND menu_items.id <> ?', parent_id, obj.id]).to_i + 1

      obj.update_attributes({:parent_id => parent_id, :menu_id => new_menu_id, :position => position})
    end
  end
end
