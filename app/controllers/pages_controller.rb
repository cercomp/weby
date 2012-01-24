class PagesController < ApplicationController
  layout :choose_layout

  before_filter :require_user, only: [:new, :edit, :update, :destroy, :sort, :toggle_field]
  before_filter :check_authorization, except: [:view, :show, :list_published]
  before_filter :per_page, only: [:index]
  before_filter :search_images, only: [:new, :edit]

  helper_method :sort_column

  respond_to :html, :xml, :js

  def index 
    params[:type] ||= 'News'
    params[:locales] ||= session[:locale]
    params[:direction] ||= 'desc'

    @pages = @site.pages.
      titles_like(params[:search], params[:locales]).
      page(params[:page]).per(per_page).
      except(:order).
      order(sort_column + " " + sort_direction)

    if !current_user
      @pages = @pages.published
    end

    @tiny_mce = tiny_mce
    #update : pode linkar todas as páginas dentro da notícia
    #@pages = @pages.published if @tiny_mce

    if @pages
      respond_with @page
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
    params[:type] ||= @page.type
    @current_locale = params[:page_loc] || session[:locale]
    respond_with(@page)
  end

  def new
    params[:type] ||= 'News'
    params[:twitter_page] ||= 1

    @page = Page.new
    @page.sites_pages.build
    @page.pages_repositories.build
    build_site_locales

    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    # Criando objeto com os arquivos que não estão relacionados com a página
    @page_files_unchecked = @site.repositories.page(params[:twitter_page]).per(params[:per_page])
  end

  def edit
    @page = Page.find(params[:id])
    # Automaticamente define o tipo da pagina, se não for passado como parâmetro
    params[:type] ||= @page.type
    params[:twitter_page] ||= 1

    build_site_locales

    @page.pages_repositories.build

    # Criando objeto com os arquivos que não estão relacionados com a página
    unless @page.repository_ids.empty?
      @page_files_unchecked = @site.repositories.where("id NOT IN (?)", @page.repository_ids).page(params[:twitter_page]).per(params[:per_page]) 
    else
      @page_files_unchecked = @site.repositories.page(params[:twitter_page]).per(params[:per_page])
    end
  end

  def create
    params[:page][:type] ||= 'News'
    params[:page][:position] = (params[:page][:front]=="0" ? 0 : max_position)
    @page = params[:page][:type].constantize.new params[:page] 
    unless @page.save
      # Recarrega variáveis para formulário
      @repository = Repository.new
      if not @page.repository_ids
        @page_files_unchecked = @site.repositories.where("id NOT IN (?)", @page.repository_ids.to_s.delete('[]')).page(1).per(params[:twitter_page].to_i*5) 
      else
        @page_files_unchecked = @site.repositories.page(1).per(params[:twitter_page].to_i*5)
      end
      build_site_locales
    end
    respond_with(@site, @page)
  end

  def update
    params[:type] ||= 'News'
    params[:page][:repository_id] ||= nil
    params[:page][:repository_ids] ||= []
    @page = Page.find(params[:id])
    p @page.page_i18ns
    if (params[:page][:front]=="1" && !@page.front)
      @page.position = max_position 
    elsif (params[:page][:front]=="0" && @page.front)
      position_down_from @page.position
      @page.position = 0
    end
    unless @page.update_attributes(params[:page])
      build_site_locales
    end
    respond_with(@site, @page)
  end

  def destroy
    @page = Page.find(params[:id])
    # deleta todas as relacoes da pagina com os sites
    SitesPage.find(@page.sites_pages).each{ |p| p.destroy }
    position_down_from @page.position if @page.front?
    @page.destroy
    redirect_to(:back)
  end

  def toggle_field
    @page = Page.find(params[:id])
    if params[:field]
      new_value = (@page[params[:field]] == 0 or not @page[params[:field]] ? true : false)
      if (params[:field]=='front' && new_value)
        @page.position = max_position 
      elsif (params[:field]=='front' && !new_value)
        position_down_from @page.position
        @page.position = 0
      end
      if @page.update_attributes("#{params[:field]}" => new_value)
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_back_or_default site_pages_path(@site)
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
    #FIXME Um update_all seria mais eficiente, porém o rails tem problemas com upate_all e joins
    #no postgres, testar no 3.2
    #Ex. @site.pages.front.where(condition).update_all("position = position +/- 1")
    @site.pages.front.where(condition).each do |page|
      page.increment(:position, increment).save
    end
    @ch_pos.update_attribute(:position, new_pos)
    render :nothing => true
  end

  # TODO teste para listar páginas na criação do componente news_as_home
  # FIXEME método semelhante ao usado pelo 'index', verificar uma maneira de agrupa-los
  # Lista com paginação as notícias cadastradas
  def list_published
    params[:locales] ||= session[:locale]
    @pages = @site.pages.
      titles_like(params[:search], params[:locales]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).per(per_page)

    @pages = @pages.published if params[:published_only]=='true'
  end

  def list_front
    @pages = @site.pages.
      except(:order).
      order("position desc")

    @pages = @pages.front
  end

  private
  def sort_column
    Page.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def max_position
    max = @site.pages.front.maximum('position')
    return max ? max+1 : 1
  end

  #FIXME Um update_all seria mais eficiente, porém o rails tem problemas com upate_all e joins
  #no postgres, testar no 3.2
  #quando tira um item da ordem, decrementa a position das pages acima dela
  def position_down_from old_position
    #@site.pages.front.update_all("position = position-1",["position > ?", old_position])
    @site.pages.front.where("position > #{old_position}").each do |page|
      page.increment(:position, -1).save
    end
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
      5
    else
      params[:per_page] || per_page_default
    end
  end

  def build_site_locales
    locales = @site.locales
    if @page.page_i18ns.size > 0
      locales = locales.
        where(["id not in (?)", @page.page_i18ns.map{|page_i18n| page_i18n.locale.id}])
    end
    locales.each do |locale|
      @page.page_i18ns.build(locale_id: locale.id)
    end
  end

  def search_images
    @images = @site.repositories.
      description_or_filename(params[:image_search]).
      content_file(["image"]).
      page(params[:page]).per(@site.per_page_default)
  end
end
