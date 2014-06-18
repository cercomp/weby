class Sites::Admin::PagesController < ApplicationController
  include ActsToToggle
  include ActsToSort

  before_action :require_user
  before_action :check_authorization

  before_action :event_types, only: [:new, :edit]

  helper_method :sort_column

  respond_to :html, :js, :json, :rss

  # GET /pages
  # GET /pages.json
  def index
    @pages = get_pages
    respond_with(:site_admin, @pages) do |format|
      if params[:template]
        format.js { render "#{params[:template]}" }
        format.html { render partial: "#{params[:template]}", layout: false }
      end
    end
  end

  def recycle_bin
    params[:sort] ||= 'pages.deleted_at'
    params[:direction] ||= 'desc'
    @pages = current_site.pages.trashed.includes(:author, :categories).
      order("#{params[:sort]} #{sort_direction}").
      page(params[:page]).per(params[:per_page])
  end

  def get_pages
    case params[:template]
    when 'tiny_mce'
      params[:per_page] = 7
    end
    params[:direction] ||= 'desc'
    # Vai ao banco por linha para recuperar
    # tags e locales
    pages = current_site.pages.
      search(params[:search], 1) # 1 = busca com AND entre termos

    if sort_column == 'tags.name'
      pages = pages.includes(categories: :taggings).order(sort_column + ' ' + sort_direction)
    else
      pages = pages.order(sort_column + ' ' + sort_direction)
    end

    pages = pages.page(params[:page]).per(params[:per_page])
  end
  private :get_pages

  def sort_column
    params[:sort] || 'pages.id'
  end
  private :sort_column

  # Essa action não chama o get_pages pois não faz paginação
  def fronts
    @pages = current_site.pages.available_fronts.order('position desc')
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = current_site.pages.find(params[:id]).in(params[:page_locale])
    if request.path != site_admin_page_path(@page)
      redirect_to site_admin_page_path(@page), status: :moved_permanently
      return
    end
    respond_with(:site_admin, @page)
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = current_site.pages.new
    respond_with(:site_admin, @page)
  end

  # GET /pages/1/edit
  def edit
    @page = current_site.pages.find(params[:id])
    respond_with(:site_admin, @page)
  end

  def event_types
    @event_types = Page::EVENT_TYPES.map { |el| t("sites.admin.pages.event_form.#{el}") }.zip(Page::EVENT_TYPES)
  end
  private :event_types

  # POST /pages
  # POST /pages.json
  def create
    @page = current_site.pages.new(page_params)
    @page.author = current_user
    @page.save
    record_activity('created_page', @page)
    respond_with(:site_admin, @page)
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    params[:page][:related_file_ids] ||= []
    @page = current_site.pages.find(params[:id])
    @page.update(page_params)
    record_activity('updated_page', @page)
    respond_with(:site_admin, @page)
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = current_site.pages.unscoped.find(params[:id])
    if @page.trash
      if @page.persisted?
        record_activity('moved_page_to_recycle_bin', @page)
        flash[:success] = t('moved_page_to_recycle_bin')
      else
        record_activity('destroyed_page', @page)
        flash[:success] = t('successfully_deleted')
      end
    else
      flash[:error] = @page.errors.full_messages.join(', ')
    end

    redirect_to :back
  end

  def recover
    @page = current_site.pages.trashed.find(params[:id])
    if @page.untrash
      flash[:success] = t('successfully_restored')
    end
    record_activity('restored_page', @page)
    redirect_to :back
  end

  private

  def page_params
    params.require(:page).permit(:type, :source, :url, :category_list, :publish,
                                 :date_begin_at, :front, :date_end_at, :image,
                                 :local, :kind, :event_email, :event_begin, :event_end,
                                 { i18ns_attributes: [:id, :locale_id, :title, :summary, :text, :_destroy],
                                   related_file_ids: [] })
  end
end
