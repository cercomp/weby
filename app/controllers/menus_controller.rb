class MenusController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :except => :show
  before_filter :check_authorization, :except => :show

  respond_to :html, :xml, :js
  def index
    params[:category] ||= @site.menu_categories.first
    unless params[:category]
      flash[:warning] = t("none_category_menu", :param => params[:category])
    end
  end

  def show
    @menu = Menu.find(params[:id])
    respond_with(@menu)
  end

  def new 
    @menu_parent = SitesMenu.find(params[:parent_id]) if params[:parent_id]
    @menu = Menu.new
    @menu.sites_menus.build
    @menu.sites_menus[0].category = params[:category] if params[:category]
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def create
    @menu = Menu.new(params[:menu])
    if @menu.save 
      flash[:notice] = t("successfully_created")
      redirect_back_or_default site_menus_path(@site, :category => @menu.sites_menus[0].category)
    else
      respond_with(@site, @menu)
    end
  end

  def update
    @menu = Menu.find(params[:id])
    old_menu_site = SitesMenu.find(@menu.sites_menus[0].id)
    if @menu.update_attributes(params[:menu])
      update_category_deep(old_menu_site, @menu.sites_menus[0].category)
      flash[:notice] = t("successfully_updated")
      redirect_back_or_default site_menus_path(@site, :category => @menu.sites_menus[0].category)
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
  def change_order
    @ch_pos = SitesMenu.find(params[:id])

    update_position_for_remove(@ch_pos)

    @ch_pos.parent_id = params[:parent_id]
    @ch_pos.position = params[:position]

    SitesMenu.where({:category => @ch_pos.category, :site_id => @ch_pos.site_id}).update_all("position = position+1",["position >= ? AND parent_id = ? ", @ch_pos.position, @ch_pos.parent_id])

    @ch_pos.save
    render :nothing => true
  end

  # Altera a categoria de um item de menu, e todos seus descendentes
  def change_category
    @ch_cat = SitesMenu.find(params[:id])

    update_category_deep(@ch_cat, params[:category])
    
    render :nothing => true
  end

  # Altera a ordenação do menu
  def change_position
    @ch_pos_new = SitesMenu.find(params[:id])
    @ch_pos_old = SitesMenu.find(:first, :conditions => ["parent_id = ? and category = ? and position = ?", @ch_pos_new.parent_id, @ch_pos_new.category, params[:position]])
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
    redirect_back_or_default site_menus_path(@site, :category => @ch_pos_new.category)
  end

  # Remove iten(s) do menu
  def rm_menu
    @rm_menu = SitesMenu.find(params[:id])
    if @rm_menu  
        ary_for_del = del_deep(@menus[@rm_menu.category], @rm_menu.id)
        ary_for_del.each do |item|
          item.destroy
      end
    end
    update_position_for_remove(@rm_menu)
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

  #Atualiza a position de todos os itens irmãos maior que obj, com position - 1
  def update_position_for_remove(obj)
    SitesMenu.where({:category => obj.category, :site_id => obj.site_id}).update_all("position = position-1",["position > ? AND parent_id = ? ", obj.position, obj.parent_id])
  end

  #obj tem que ter o atributo category, sua antiga category, seu antigo parent_id e antiga position
  def update_category_deep(obj, new_category)
    if (obj && obj.category!=new_category)
      ary_for_up = del_deep(@menus[obj.category], obj.id)
      ary_for_up.each do |item|
        item.category = new_category
        item.save
      end
      update_position_for_remove(obj)
      parent_id = 0
      position = SitesMenu.maximum('position', :conditions=> ['category = ? AND site_id = ? AND parent_id = ? AND id <> ?', new_category, obj.site_id, parent_id, obj.id])+1

      obj.update_attributes({:parent_id => parent_id, :category => new_category, :position => position})
    end
  end
end
