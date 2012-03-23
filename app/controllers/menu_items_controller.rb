class MenuItemsController < ApplicationController
  layout :choose_layout
  before_filter :get_current_menu
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    #
  end

  def show
    #
  end

  def new
    get_parent_menu_item params[:parent_id]
    @menu_item = @menu.menu_items.new
    build_locales
  end

  def edit
    @menu_item = @menu.menu_items.find(params[:id])
    build_locales
  end

  def create
    @menu_item = @menu.menu_items.new(params[:menu_item])
    @menu_item.position = @menu.menu_items.maximum('position', :conditions=> ['parent_id = ?', @menu_item.parent_id]).to_i + 1
    if @menu_item.save
      flash[:notice] = t("successfully_created")
      redirect_back_or_default site_menus_path(@site, :menu => @menu.id)
    else
      get_parent_menu_item params[:menu_item][:parent_id]
      build_locales
      respond_with(@site, @menu, @menu_item)
    end
  end

  def update
    @menu_item = @menu.menu_items.find(params[:id])
    if @menu_item.update_attributes(params[:menu_item])
      flash[:notice] = t("successfully_updated")
      redirect_back_or_default site_menus_path(@site, :menu => @menu.id)
    else
      build_locales
      respond_with(@site, @menu, @menu_item)
    end
  end

  def destroy
    #
  end

   # Remove iten(s) do menu
  def rm_menu
    @menu_item = @menu.menu_items.find(params[:id])
    ary_for_del = del_deep(@global_menus[@menu.id], @menu_item.id)
    ary_for_del.each do |item|
       item.destroy
    end
    update_position_for_remove(@menu_item)
    @menu_item.destroy
    redirect_to :back, :notice => t("successfully_deleted")
  end

  # Altera a ordenação do menu
  def change_order
    @ch_pos = @menu.menu_items.find(params[:id])

    update_position_for_remove(@ch_pos)

    @ch_pos.parent_id = params[:parent_id]
    @ch_pos.position = params[:position]

    idx = 1
    @menu.menu_items.where({:parent_id => @ch_pos.parent_id}).order('position').each { |smenu|
      if(smenu.id != @ch_pos.id)
        if(idx == @ch_pos.position)
          idx += 1
        end
        smenu.update_attribute(:position, idx)
        idx += 1
      end
    }

    @ch_pos.save
    render :nothing => true
  end

  # Altera o menu de um item de menu, e todos seus descendentes
  def change_menu
    @ch_menu = @menu.menu_items.find(params[:id])
    change_menu_deep(@ch_menu, params[:new_menu_id])
    
    render :nothing => true
  end

  # Altera a ordenação do menu
  #def change_position
  #  @ch_pos_new = @menu.menu_items.find(params[:id])
  #  @ch_pos_old = @menu.menu_items.find(:first, :conditions => ["parent_id = ? and position = ?", @ch_pos_new.parent_id, params[:position]])
  #  if @ch_pos_old
  #    @ch_pos_new.position,@ch_pos_old.position = @ch_pos_old.position,@ch_pos_new.position
  #    @ch_pos_new.save
  #    @ch_pos_old.save
  #    flash[:notice] = t"successfully_updated"
  #  elsif params[:position]
  #    @ch_pos_new.position = params[:position]
  #    @ch_pos_new.save
  #  else
  #    flash[:error] = t"error_updating_object"
  #  end
  #  redirect_to :back, :notice => t("successfully_deleted")
  #end
 

  private
  def get_current_menu
    @menu = @site.menus.find(params[:menu_id])
  end

  def get_parent_menu_item parent_id
    if parent_id
      @menu_item_parent = @menu.menu_items.find(parent_id)
      @parent_i18n = @menu_item_parent.i18n(session[:locale])
    end
  end

  def build_locales
    available_locales.each do |locale|
      @menu_item.i18ns.build(locale_id: locale.id)
    end
  end

  def available_locales
    locales = @site.locales
    if @menu_item.i18ns.size > 0
      locales = locales.
        where(["id not in (?)", @menu_item.i18ns.
               map{|menu_item_i18n| menu_item_i18n.locale.id}])
    end

    locales
  end

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

  #Atualiza a position de todos os itens menos o do obj, assumindo que ele irá para outro parent_id
  def update_position_for_remove(obj)
    idx = 1
    @menu.menu_items.where({:parent_id => obj.parent_id}).order('position').each { |menuis|
      if menuis.id != obj.id
        menuis.update_attribute(:position, idx)
        idx += 1
      end
    }
  end

  #obj tem que ter o atributo menu_id, seu antigo menu_id, seu antigo parent_id e antiga position
  def change_menu_deep(obj, new_menu_id)
    if (obj && obj.menu_id!=new_menu_id)
      ary_for_up = del_deep(@global_menus[@menu.id], obj.id)
      ary_for_up.each do |item|
        item.menu_id = new_menu_id
        item.save
      end
      update_position_for_remove(obj)
      parent_id = 0
      max = @site.menu_items.maximum('position', :conditions=> ['menu_id = ? AND parent_id = ? AND menu_items.id <> ?', new_menu_id, parent_id, obj.id])
      position = max ? max+1 : 1

      obj.update_attributes({:parent_id => parent_id, :menu_id => new_menu_id, :position => position})
    end
  end
end