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

  def fronts
    params[:published] ||= 'true'
    @pages = @site.pages.front.order('position desc')
    if(params[:published]=='true')
      @pages = @pages.valid
    end
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
    @site.locales.each {|locale| @page.i18ns.build(locale_id: locale.id)}
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
    params[:page][:position] = (params[:page][:front]=="0" ? 0 : max_position)
    @page = @site.pages.new(params[:page])
    @page.author = current_user
    @page.save
    respond_with(@site, @page)
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    params[:page][:related_file_ids] ||= []
    @page = @site.pages.find(params[:id])
    update_position_of @page, @page.front, params[:page][:front]
    @page.update_attributes(params[:page])
    respond_with(@site, @page)
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = @site.pages.find(params[:id])
    @page.destroy
    position_down_from @page.position if @page.front?
    respond_with(@site, @page)
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

  def toggle_field
    @page = @site.pages.find(params[:id])
    if params[:field]
      new_value = (@page[params[:field]] == 0 or not @page[params[:field]] ? true : false)

      if (params[:field]=='front')
        update_position_of @page, @page.front, new_value
      end

      if @page.update_attributes!("#{params[:field]}" => new_value)
        flash[:notice] = t("successfully_updated")
      else
        flash[:notice] = t("error_updating_object")
      end
    end
    redirect_to :back
  end

  #Se a pagina está deixando de ser capa ou passando a ser capa, atualiza o position de acordo
  def update_position_of(page, old_front_value, new_front_value)
    if ((not old_front_value or old_front_value=='0') and (new_front_value or new_front_value=='1'))
      page.position = max_position
    elsif ((old_front_value or old_front_value=='1') and (not new_front_value or new_front_value=='0'))
      position_down_from page.position
      page.position = 0
    end
  end
  private :update_position_of

  def max_position
    @site.pages.front.maximum('position').to_i + 1
  end
  private :max_position

  def position_down_from old_position
    @site.pages.front.where("position > #{old_position}").
      update_all("position = position-1") if old_position
  end
  private :position_down_from

end
