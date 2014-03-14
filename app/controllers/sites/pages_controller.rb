class Sites::PagesController < ApplicationController
  layout :choose_layout

  helper_method :sort_column
  before_filter :check_current_site
  
  respond_to :html, :js, :json, :rss

  # GET /pages
  # GET /pages.json
  def index
    if params[:tags]
      @pages = get_pages.available.tagged_with(tags, any: true)
    else
      @pages = get_pages.available
    end
    respond_with(:site, @page) do |format|
      format.rss { render :layout => false, :content_type => Mime::XML } #index.rss.builder
      format.atom { render :layout => false, :content_type => Mime::XML } #index.atom.builder
    end
  end

  def events
    @pages = get_pages.available.send(params[:upcoming] ? :upcoming_events : params[:previous] ? :previous_events : :events)

    respond_with(current_site, @pages) do |format|
      format.any { render 'index' }
    end
  end

  def news
    @pages = get_pages.available.news
    respond_with(current_site, @pages) do |format|
      format.any { render 'index'}
    end
  end

  def tags
    params[:tags].split(',')
  end
  private :tags

  def get_pages
    params[:direction] ||= 'desc'
    # Vai ao banco por linha para recuperar
    # tags e locales
    current_site.pages.
      search(params[:search], params.fetch(:search_type, 1).to_i).
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
    @page = current_site.pages.find(params[:id])
    if request.path != site_page_path(@page)
      redirect_to site_page_path(@page), status: :moved_permanently
      return
    end

    respond_with(:site, @page)
  end

  def sort
    @ch_pos = current_site.pages.find(params[:id_moved], :readonly => false)
    increment = 1
    #Caso foi movido para o fim da lista ou o fim de uma pagina(quando paginado)
    if(params[:id_after] == '0')
      @before = current_site.pages.find(params[:id_before])
      condition = "position < #{@ch_pos.position} AND position >= #{@before.position}"
      new_pos = @before.position
    else
      @after = current_site.pages.find(params[:id_after])
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
    current_site.pages.front.where(condition).update_all("position = position + (#{increment})")
    @ch_pos.update_attribute(:position, new_pos)
    render :nothing => true
  end

  private
  def check_current_site
    render_404 if not current_site
  end

end
