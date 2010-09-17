class MenusController < ApplicationController
  require 'pp'
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization, :except => [:new, :create, :edit, :update]

  respond_to :html, :xml, :js

  def index
    if params[:site_id]
      top_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'top'")
      left_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'left'")
      right_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'right'")
      bottom_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.position = 'bottom'")
    else
      top_untreated = "" 
      left_untreated = ""
      right_untreated = ""
      bottom_untreated = ""
    end

    @ll = left_untreated.clone    
    @aux = ""
    @left = menu_treat(left_untreated) 
    @right = menu_treat(right_untreated) 
    @top = menu_treat(top_untreated) 
    @bottom = menu_treat(bottom_untreated) 
  end

  # Metodo para tratar o menu
  def menu_treat(obj)
    result = []
    i = 0 
    obj.sort!{|x,y| x.id <=> y.id }
    while i < obj.size
      l = obj[i]
      result << l
      obj.delete(l)
      result_test = search_son(l.id, obj)
      result << result_test unless result_test.empty?
    end
    return result
  end
  # Procura pelo id de um filho (id) em um dado vetor (arr)
  def search_son(id, arr)
    result = []
    i = 0 
    while i < arr.size
      a = arr[i]
      @aux += "#{id} == #{a.parent_id} (#{a.id}) | "
      if id.to_s == a.parent_id
        #logger.debug "O id:#{id} é pai do #{a.id}"
        result << a
        arr.delete(a)
        #logger.debug "Sub recursão search_son(#{a.id}, [#{arr.to_s}])"
        res_test = search_son(a.id, arr)
        result << res_test unless res_test.empty?
      else
        i = i + 1 
      end 
    end 
    return result
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
    redirect_to :back, :notice => "Successfully created." 
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
  
  def rm_menu
    @rm_menu = SitesMenu.find(params[:id])
    @rm_menu.destroy
    redirect_to :back, :notice => "Successfully deleted." 
  end
end
