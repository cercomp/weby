class Admin::SitesController < Admin::BaseController
  before_action :set_resource, only: [:edit, :update, :destroy]

  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= current_settings.per_page_default

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + ' ' + sort_direction)

    if params[:status_filter].present?
      @sites = @sites.where(status: params[:status_filter])
    end

    @sites = @sites.page(params[:page]).per(params[:per_page])
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)

    if @site.save
      Weby::Rights.seed_roles @site.id
      record_activity('created_site', @site)
      redirect_to site_admin_skins_url(subdomain: @site)
    else
      respond_with @site
    end
  end

  def edit
  end

  def update
    if @site.update(site_params)
      flash[:success] = t'successfully_updated'
      record_activity('updated_site', @site)
      redirect_to params[:return_to] == 'index' ? admin_sites_path : edit_admin_site_path(@site.id)
    else
      if params[:return_to] == 'index'
        flash[:alert] = t('problem_update_site')
        redirect_to admin_sites_path
      else
        render :edit
      end
    end
  end

  def destroy
    Calendar::Event.unscoped do
      Journal::News.unscoped do
        Repository.unscoped do
          Page.unscoped do
            @site.destroy
          end
        end
      end
    end
    flash[:success] = t('successfully_deleted')
    redirect_to admin_sites_url(subdomain: nil)
  end

  private

  def set_resource
    resource
  end

  def site_params
    params.require(:site).permit(:title, :top_banner_id, :name, :parent_id, :url,
                                 :domain, :description, :view_desc_pages, :theme,
                                 :body_width, :per_page, :per_page_default, :status,
                                 {locale_ids: [], grouping_ids: []})
  end

  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end
