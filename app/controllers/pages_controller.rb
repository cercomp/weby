class PagesController < ApplicationController
  layout :choose_layout

  before_filter :require_user, only: [:new, :edit, :update, :destroy, :sort, :toggle_field]
  before_filter :check_authorization, except: [:view, :show, :list_published]

  before_filter :event_types, only: [:new, :edit]

  helper_method :sort_column

  respond_to :html, :js, :json

  before_filter :get_pages, only: [:index, :published]

  # GET /pages
  # GET /pages.json
  def index
    (redirect_to published_site_pages_path(@site) unless current_user) and return
    @pages = get_pages 
    respond_with(@site, @page)
  end

  def published
    @pages = get_pages.published
    respond_with(@site, @page) do |format|
      format.html { render template: 'pages/index' }
    end
  end

  def tiny_mce
    params[:per_page] = 7
    @pages = get_pages
    respond_with(@site, @page)
  end

  def get_pages
    # Vai ao banco por linha para recuperar
    # tags e locales
    @site.pages.
      includes(:author, :categories).
      page(params[:page]).per(params[:per_page]).
      order(sort_column + " " + sort_direction)
  end
  private :get_pages

  def sort_column
    params[:sort] || 'pages.id'
  end
  private :sort_column

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = @site.pages.find(params[:id])
    respond_with(@site, @page)
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = @site.pages.new
    @site.locales.each {|locale| @page.translations.build(locale: locale.name)}
    respond_with(@site, @page)
  end

  # GET /pages/1/edit
  def edit
    @page = @site.pages.find(params[:id])
    respond_with(@site, @page)
  end

  def event_types
    @event_types = Page::EVENT_TYPES.map {|el| t("pages.event_form.#{el}")}.zip(Page::EVENT_TYPES)
  end
  private :event_types


  # POST /pages
  # POST /pages.json
  def create
    @page = @site.pages.new(params[:page])
    @page.author = current_user
    @page.save
    respond_with(@site, @page)
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = @site.pages.find(params[:id])
    @page.update_attributes(params[:page])
    respond_with(@site, @page)
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = @site.pages.find(params[:id])
    @page.destroy
    respond_with(@site, @page)
  end

end
