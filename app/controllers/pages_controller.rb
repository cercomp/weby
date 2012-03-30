class PagesController < ApplicationController
  layout :choose_layout

  before_filter :require_user, only: [:new, :edit, :update, :destroy, :sort, :toggle_field]
  before_filter :check_authorization, except: [:view, :show, :list_published]
  before_filter :per_page, only: [:index]
  before_filter :search_images, only: [:new, :edit]

  helper_method :sort_column

  respond_to :html, :xml, :js

  def index 
    params[:locales] ||= session[:locale]
    params[:direction] ||= 'desc'
    extra_order = params[:sort]=='front' ? ',position desc' : ''

    @pages = @site.pages.
      titles_like(params[:search], params[:locales]).
      order(sort_column + " " + sort_direction+ extra_order).
      page(params[:page]).per(per_page)

    if !current_user
      @pages = @pages.published
    end

    @tiny_mce = tiny_mce

    if @pages
      respond_with @pages
    else
      flash[:warning] = (t"none_param", param: t("page.one"))
    end
  end

  def show
    begin
      @page = @site.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t(:page_not_found)+" [#{params[:id]}]"
      redirect_to :action => 'index' and return
    end
    @current_locale = params[:page_loc] || session[:locale]
    respond_with(@page)
  end

  def new
    @page = Page.new
    @page.sites_pages.build
    build_site_locales
    @page.pages_repositories.build
  end

  def edit
    @page = @site.pages.find(params[:id])
    build_site_locales
    @page.pages_repositories.build
  end

  def create
    # Remove type of params because type can't be setted on create
    type = params[:page].delete(:type)
    type ||= 'News'
    params[:page][:position] = (params[:page][:front]=="0" ? 0 : max_position)

    @page = Page.new(params[:page])

    # Set type of page, this can't be setted on create
    @page.type = type
    params[:page][:type] ||= 'News'

    @page.author_id = @current_user.id

    unless @page.save
      @page.pages_repositories.build
      @page.sites_pages.build
      build_site_locales
    end
    respond_with(@site, @page)
  end

  def update
    params[:page][:repository_ids] ||= []
    # Remove type of params because type can't be setted on update_attributes
    params[:page].delete(:type)

    @page = @site.pages.find(params[:id])

    update_position_of @page

    unless @page.update_attributes(params[:page])
      build_site_locales
    end
    respond_with(@site, @page)
  end

  def destroy
    @page = @site.pages.find(params[:id])
    # deleta todas as relacoes da pagina com os sites
    SitesPage.find(@page.sites_pages).each{ |p| p.destroy }
    @page.destroy
    position_down_from @page.position if @page.front?
    redirect_to(:back)
  end

  def toggle_field
    @page = @site.pages.find(params[:id])
    if params[:field]
      new_value = (@page[params[:field]] == 0 or not @page[params[:field]] ? true : false)
      if (params[:field]=='front' && new_value)
        @page.position = max_position 
      elsif (params[:field]=='front' && !new_value)
        position_down_from @page.position
        @page.position = 0
      end
      if @page.update_attributes("#{params[:field]}" => new_value)
        flash[:notice] = t("successfully_updated")
      else
        flash[:notice] = t("error_updating_object")
      end
    end
    redirect_to :back
  end

  def sort
    @ch_pos = @site.pages.find(params[:id_moved], :readonly => false)
    increment = 1
    #Caso foi movido para o fim da lista ou o fim de uma pagina(quando paginado)
    if(params[:id_after] == '0')
      @before = @site.pages.find(params[:id_before])
      condition = "position < #{@ch_pos.position} AND position >= #{@before.position}"
      new_pos = @before.position
    else
      @after = @site.pages.find(params[:id_after])
      other_pos = @after.position
      #Caso foi movido de cima pra baixo
      if(@ch_pos.position > @after.position)
        condition = "position < #{@ch_pos.position} AND position > #{other_pos}"
        new_pos = @after.position+1
        #Caso foi movido de baixo pra cima
      else
        increment = -1
        condition = "position > #{@ch_pos.position} AND position <= #{other_pos}"
        new_pos = @after.position
      end
    end
    @site.pages.front.where(condition).update_all("position = position + (#{increment})")
    @ch_pos.update_attribute(:position, new_pos)
    render :nothing => true
  end

  # TODO teste para listar páginas na criação do componente news_as_home
  # FIXME método semelhante ao usado pelo 'index', verificar uma maneira de agrupa-los
  # Lista com paginação as notícias cadastradas
  def list_published
    params[:locales] ||= session[:locale]
    params[:direction] = 'desc'
    @pages = @site.pages.
      titles_like(params[:search], params[:locales]).
      order(sort_column + " " + sort_direction).
      page(params[:page]).per(per_page)

    @pages = @pages.published if params[:published_only]=='true'
  end

  def list_front
    params[:published] ||= 'false'
    @pages = @site.pages.order("position desc")

    if(params[:published]=='false')
      @pages = @pages.news(true)
    else
      @pages = @pages.front
    end
  end

  private
  def sort_column
    Page.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def max_position
    max = @site.pages.front.maximum('position')
    max.to_i + 1
  end

  def update_position_of(page)
    if (params[:page][:front]=="1" && !page.front)
      page.position = max_position 
    elsif (params[:page][:front]=="0" && page.front)
      position_down_from page.position
      page.position = 0
    end
  end

  def position_down_from old_position
    @site.pages.front.where("position > #{old_position}").
      update_all("position = position-1") if old_position
  end

  def tiny_mce
    if params.include? :tiny_mce 
      %w(true yes T t 1).include? params[:tiny_mce]
    else
      false
    end
  end

  def per_page
    if tiny_mce
      7
    else
      params[:per_page] || per_page_default
    end
  end

  def build_site_locales
    available_locales.each do |locale|
      @page.page_i18ns.build(locale_id: locale.id)
    end
  end

  def available_locales
    locales = @site.locales
    if @page.page_i18ns.size > 0
      locales = locales.
        where(["id not in (?)", @page.page_i18ns.
               map{|page_i18n| page_i18n.locale.id}])
    end

    locales
  end

  def search_images
    @images = @site.repositories.
      description_or_filename(params[:image_search]).
      content_file(["image"]).
      page(params[:page]).per(@site.per_page_default)
  end
end
