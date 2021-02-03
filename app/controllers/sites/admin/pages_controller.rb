class Sites::Admin::PagesController < ApplicationController
  include ActsToToggle

  before_action :require_user
  before_action :check_authorization

  helper_method :sort_column

  respond_to :html, :js, :json, :rss

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
    @pages = current_site.pages.trashed.includes(:user).
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
    pages = current_site.pages.includes(:user)
    if params[:template] == 'list_popup'
      pages = pages.published
    end
      pages.with_search(params[:search], 1) # 1 = busca com AND entre termos
      .order(sort_column + ' ' + sort_direction)
      .page(params[:page]).per(params[:per_page])
  end
  private :get_pages

  def sort_column
    params[:sort] || 'pages.id'
  end
  private :sort_column

  def show
    @page = current_site.pages.find(params[:id]).in(params[:show_locale])
  end

  def new
    @page = current_site.pages.new_or_clone(params[:copy_from])
  end

  def edit
    @page = current_site.pages.find(params[:id])
  end

  def create
    @page = current_site.pages.new(page_params)
    @page.user = current_user
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

    redirect_to @page.persisted? ? site_admin_pages_path : recycle_bin_site_admin_pages_path
  end

  def recover
    @page = current_site.pages.trashed.find(params[:id])
    if @page.untrash
      flash[:success] = t('successfully_restored')
    end
    record_activity('restored_page', @page)
    redirect_back(fallback_location: recycle_bin_site_admin_pages_path)
  end

  def destroy_many
    pages = current_site.pages.where(id: params[:ids].split(',')).each do |page|
      if page.trash
        record_activity('moved_page_to_recycle_bin', page)
        flash[:success] = t('moved_page_to_recycle_bin')
      end
    end
    redirect_back(fallback_location: site_admin_pages_path)
  end


  def empty_bin
    if current_site.pages.trashed.destroy_all
      flash[:success] = t('successfully_deleted')
    end
    redirect_to main_app.recycle_bin_site_admin_pages_path
  end

  private

  def page_params
    params.require(:page).permit(:publish,
                                 { i18ns_attributes: [:id, :locale_id, :title, :text, :_destroy],
                                 related_file_ids: [] })
  end
end
