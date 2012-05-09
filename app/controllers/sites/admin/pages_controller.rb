class Sites::Admin::PagesController < ApplicationController

  before_filter :require_user, only: [:new, :edit, :update, :destroy, :sort, :toggle_field]
  before_filter :check_authorization, except: [:view, :show, :published]

  before_filter :event_types, only: [:new, :edit]

  helper_method :sort_column

  respond_to :html, :js, :json, :rss

  # GET /pages
  # GET /pages.json
  def index
    (redirect_to published_site_pages_path(@site) unless current_user) and return
    @pages = get_pages 
    respond_with(@site, @page) do |format|
      if(params[:template])
        format.js { render template: "pages/#{params[:template]}" }
      end
    end
  end

  def published
    @pages = get_pages.published
    respond_with(@site, @page) do |format|
      format.rss { render :layout => false, :content_type => Mime::XML } #published.rss.builder
      format.atom { render :layout => false, :content_type => Mime::XML } #ublished.atom.builder
      format.any { render template: 'pages/index' }
    end
  end

  def get_pages
    case params[:template]
    when "tiny_mce"
      params[:per_page] = 7
    end
    params[:direction] ||= 'desc'
    # Vai ao banco por linha para recuperar
    # tags e locales
    @site.pages.
      search(params[:search]).
      page(params[:page]).per(params[:per_page]).
      order(sort_column + " " + sort_direction)
  end
  private :get_pages

  def sort_column
    params[:sort] || 'pages.id'
  end
  private :sort_column

  #Essa action não chama o get_pages pois não faz paginação
  def fronts
    params[:published] ||= 'true'
    @pages = @site.pages.front.order('position desc')
    @pages = @pages.available if params[:published] == 'true' 
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = @site.pages.find(params[:id]).in(params[:page_locale])
    respond_with(@site, @page)
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = @site.pages.new
    @available_locales = available_locales
    respond_with(@site, @page)
  end

  # GET /pages/1/edit
  def edit
    @page = @site.pages.find(params[:id])
    @available_locales = available_locales
    respond_with(@site, @page)
  end

  def available_locales
    (@page.locales | @site.locales).sort
  end
  private :available_locales

  def event_types
    @event_types = Page::EVENT_TYPES.map {|el| t("pages.event_form.#{el}")}.zip(Page::EVENT_TYPES)
  end
  private :event_types

  # POST /pages
  # POST /pages.json
  def create
    @page = @site.pages.new(params[:page])
    @available_locales = available_locales
    @page.author = current_user
    @page.save
    respond_with(@site, @page)
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    params[:page][:related_file_ids] ||= []
    @page = @site.pages.find(params[:id])
    @available_locales = available_locales
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

  def toggle_field
    @page = @site.pages.find(params[:id])
    @page.toggle!(params[:field])
    respond_with(@page) do |format|
      format.any { redirect_to site_admin_pages_path(@site) }
    end
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
      #Caso foi movido de cima pra baixo
      if(@ch_pos.position > @after.position)
        condition = "position < #{@ch_pos.position} AND position > #{@after.position}"
        new_pos = @after.position+1
        #Caso foi movido de baixo pra cima
      else
        increment = -1
        condition = "position > #{@ch_pos.position} AND position <= #{@after.position}"
        new_pos = @after.position
      end
    end
    @site.pages.front.where(condition).update_all("position = position + (#{increment})")
    @ch_pos.update_attribute(:position, new_pos)
    render :nothing => true
  end
end
