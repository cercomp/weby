class PagesController < ApplicationController
  layout :choose_layout
  before_filter :require_user, only: [:new, :edit, :update, :destroy, :sort, :toggle_field]
  before_filter :check_authorization, except: [:view, :show]
  before_filter :per_page, only: [:index]
  helper_method :sort_column

  respond_to :html, :xml, :js

  def index 
    params[:type] ||= 'News'
    params[:locales] ||= session[:locale]

    @pages = @site.pages.titles_like(params[:search], params[:locales])
    if current_user
      @pages = @pages.except(:order).order(sort_column + " " + sort_direction).
        page(params[:page]).per(per_page)
    else
      @pages = @pages.published.except(:order).order(sort_column + " " + sort_direction).
        page(params[:page]).per(per_page)
    end

    @tiny_mce = tiny_mce
    @pages = @pages.published if @tiny_mce

    if @pages
      respond_with @page
    else
      flash[:warning] = (t"none_param", param: t("page.one"))
    end
  end

  def show
    @page = Page.find(params[:id])
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


    @images = @site.repositories.content_file("image").
      page(params[:page]).per(params[:per_page])

    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    # Criando objeto com os arquivos que não estão relacionados com a página
    @page_files_unchecked = @site.repositories.page(params[:twitter_page]).per(params[:per_page])
  end

  def edit
    @page = Page.find(params[:id])
    # Automaticamente define o tipo da pagina, se não for passado como parâmetro
    params[:type] ||= @page.type
    params[:twitter_page] ||= 1

    @locales = @page.page_i18ns.map{|i18n| Locale.find(i18n.locale_id).name}

    @page.pages_repositories.build

    @images = @site.repositories.content_file("image").
      page(params[:page]).per(params[:per_page])

    # Criando objeto com os arquivos que não estão relacionados com a página
    unless @page.repository_ids.empty?
      @page_files_unchecked = @site.repositories.where("id NOT IN (?)", @page.repository_ids).page(params[:twitter_page]).per(params[:per_page]) 
    else
      @page_files_unchecked = @site.repositories.page(params[:twitter_page]).per(params[:per_page])
    end
  end

  def create
    params[:page][:type] ||= 'News'
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
    @page = Page.find(params[:id])
    # Se não houver nenhum checkbox marcado, remover todos.
    params[@page.type.downcase.to_s][:repository_ids] ||= [] 
    if @page.update_attributes(params[@page.type.downcase.to_s])
      flash[:notice] = t"successfully_updated"
    end
    #respond_with(@page, location: site_pages_path(type: params[:type]))
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

  # Actions referêntes ao gerenciamento de internacionalizações
  def add_i18n
    flash[:warning] = t("edit_yours_i18ns")
    @page = Page.find(params[:id])
    @page_i18n = PageI18n.new(page_id: @page.id)
    # Available languages
    @langs = Locale.all - @page.page_i18ns.map{|p| p.locale}
  end

  def create_i18n
    @page_i18n = PageI18n.new(params[:page_i18n])
    if @page_i18n.save
      # TODO escrever 18n da frase 'Sucesso'
      redirect_to site_page_url(@site, @page_i18n.page, page_loc: @page_i18n.locale.name), notice: 'Sucesso'
    else
      @page = @page_i18n.page
      @langs = Locale.all - @page.page_i18ns.map{|p| p.locale}
      render :add_i18n
    end
  end

  # TODO teste para listar páginas na criação do componente news_as_home
  # FIXEME método semelhante ao usado pelo 'index', verificar uma maneira de agrupa-los
  # Lista com paginação as notícias cadastradas
  def list_published
    params[:locales] ||= session[:locale]
    @pages = @site.pages.titles_like(params[:search], params[:locales]).except(:order).order(sort_column + " " + sort_direction).
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

  def build_site_locales
    @site.locales.each do |locale|
      @page.page_i18ns.build(locale_id: locale.id)
    end
  end
end
