class PagesController < ApplicationController
  layout :choose_layout

  before_filter :require_user, only: [:new, :edit, :update, :destroy, :sort, :toggle_field]
  before_filter :check_authorization, except: [:view, :show, :list_published]

  helper_method :sort_column

  respond_to :html, :js, :json

  before_filter :get_pages, only: [:index, :published]

  # GET /pages
  # GET /pages.json
  def index
    return published unless current_user
    @pages = get_pages 
  end

  def published
    @pages = get_pages.published
    render template: 'pages/index'
  end

  def get_pages
    # Vai ao banco por linha para recuperar
    # tags e locales
    @site.pages.
      includes(:translations, :author, :categories).
      page(params[:page]).per(params[:per_page]).
      order("page_translations.locale asc," + sort_column + " " + sort_direction)
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
    respond_with @page
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = @site.pages.new
    @site.locales.each { |locale| @page.translations.build(locale: locale.name) }
    respond_with @page
  end

  # GET /pages/1/edit
  def edit
    @page = @site.pages.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = @site.pages.new(params[:page])
    @page.author = current_user

    respond_to do |format|
      if @page.save
        format.html { redirect_to [@site, @page], notice: 'Page was successfully created.' }
        format.json { render json: @page, status: :created, location: @page }
      else
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = @site.pages.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to [@site, @page], notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = @site.pages.find(params[:id])
    @page.destroy

    respond_with @page
  end

end
