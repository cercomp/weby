class PagesController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :only => [:new, :edit, :update, :destroy, :sort, :toggle_field]
  before_filter :check_authorization, :except => [:view, :show]
  before_filter :per_page, :only => [:index]
  before_filter :load_images, :only => [:edit, :new]
  helper_method :sort_column

  respond_to :html, :xml, :js
  def index 
    params[:type] ||= 'News'

    @tiny_mce = tiny_mce

    @pages = @site.pages.titles_like(params[:search])

    @pages = @pages.except(:order).order(sort_column + " " + sort_direction).
      page(params[:page]).per(per_page)

    @pages = @pages.published if @tiny_mce

    if @pages
      respond_with @page
    else
      flash[:warning] = (t"none_param", :param => t("page.one"))
    end
  end

  def show
    @page = Page.find(params[:id])
    params[:type] ||= @page.type
    respond_with(@page)
  end

  def new
    params[:type] ||= 'News'
    params[:twitter_page] ||= 1

    @repository = Repository.new
    @page = Page.new
    @page.sites_pages.build
    @page.pages_repositories.build
    @repos = @site.repositories.page(params[:page]).per(params[:per_page])

    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    ## Criando objeto com os arquivos que não estão relacionados com a página
    @page_files_unchecked = @site.repositories.page(1).per(params[:twitter_page])
  end

  def edit
    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    @page = Page.find(params[:id])
    # Automaticamente define o tipo, se não for passado como parâmetro
    params[:type] ||= @page.type
    params[:twitter_page] ||= 1

    @repository = Repository.new
    @page.pages_repositories.build
    @repos = @site.repositories.page(params[:page]).per(params[:per_page])

    # Criando objeto com os arquivos que não estão relacionados com a página
    unless @page.repository_ids.empty?
      @page_files_unchecked = @site.repositories.where("id NOT IN (?)", @page.repository_ids).page(1).per(params[:twitter_page]*5) 
    else
      @page_files_unchecked = @site.repositories.page(1).per(params[:twitter_page]*5)
    end
  end

  def create
    params[:page][:type] ||= 'News'
    @page = Object.const_get(params[:page][:type]).new(params[:page])
    @page.save
    respond_with(@page, :location => site_pages_path(:type => params[:type]))
  end

  def update
    @page = Page.find(params[:id])
    # Se não houver nenhum checkbox marcado, remover todos.
    params[@page.type.downcase.to_s][:repository_ids] ||= [] 
    if @page.update_attributes(params[@page.type.downcase.to_s])
      flash[:notice] = t"successfully_updated"
    end
    #respond_with(@page, :location => site_pages_path(:type => params[:type]))
    redirect_to site_page_path(@site, @page)
  end

  def destroy
    @page = Page.find(params[:id])
    # deleta todas as relacoes da pagina com os sites
    SitesPage.find(@page.sites_pages).each{ |p| p.destroy }
    @page.destroy
    redirect_to(:back)
  end

  def toggle_field
    @page = Page.find(params[:id])
    if params[:field] 
      if @page.update_attributes("#{params[:field]}" => (@page[params[:field]] == 0 or not @page[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_back_or_default site_pages_path(@site)
  end

  def sort
    @pages = @site.pages.page(params[:page]).per(10)
    @front_news = @site.pages.news(true)
    @no_front_news = @site.pages.news(false).page(params[:page]).per(5)

    params['sort_page'] ||= []
    params['sort_page'].to_a.each do |p|
      page = Page.find(p)
      page.position = (params['sort_page'].index(p) + 1)
      page.save
    end
  end
  
  # TODO teste para listar páginas na criação do componente news_as_home
  # FIXEME método semelhante ao usado pelo 'index', verificar uma maneira de agrupa-los
  # Lista com paginação as notícias cadastradas
  def list_published
    @pages = @site.pages.titles_like(params[:search]).except(:order).order(sort_column + " " + sort_direction).
      page(params[:page]).per(per_page)

    @pages = @pages.published
  end

  private
  def sort_column
    Page.column_names.include?(params[:sort]) ? params[:sort] : 'position, id'
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
end
