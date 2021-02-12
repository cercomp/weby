class Admin::SitesController < Admin::BaseController
  include ActsToToggle

  before_action :set_resource, only: [:edit, :update, :destroy, :reindex]

  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= current_settings.per_page_default

    if params[:search].to_s.match(/^\d+$/)
      @sites = Site.where(id: params[:search])
    else
      @sites = Site.name_or_description_like(params[:search])
    end
    @sites = @sites.except(:order).order("#{sort_column} #{sort_direction}")

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
    load_subsites
  end

  def update
    if @site.update(site_params)
      if @site.previous_changes["status"] == ["active", "inactive"] # check if status was changed from active to inactive
        ::SiteMailer.site_deactivated(@site)
      end
      flash[:success] = t'successfully_updated'
      record_activity('updated_site', @site)
      redirect_to params[:return_to] == 'index' ? admin_sites_path : edit_admin_site_path(@site.id)
    else
      if params[:return_to] == 'index'
        flash[:alert] = t('problem_update_site')
        redirect_to admin_sites_path
      else
        load_subsites
        render :edit
      end
    end
  end

  def destroy
    begin
      @site.unscoped_destroy!
      flash[:success] = t('successfully_deleted')
    rescue ActiveRecord::RecordNotDestroyed => error
      flash[:warning] = "#{t('error_destroying_object')}: #{error.record.errors.full_messages.join(', ')}"
    end
    redirect_to admin_sites_url(subdomain: nil)
  end

  def reindex
    @site.news_sites.reindex
    @site.page.reindex
    @site.events.reindex
    flash[:notice] = t('.news_reindexed')
    redirect_to edit_admin_site_path(@site)
  end

  private

  def load_subsites
    @sites = @site.subsites.active
      .includes(:main_site)
      .except(:order)
      .order("#{sort_column} #{sort_direction}")
      .page(params[:page])
      .per(params[:per_page])
  end

  def set_resource
    resource
  end

  def site_params
    params.require(:site).permit(:title, :top_banner_id, :name, :parent_id,
                                 :domain, :description, :show_pages_author,
                                 :show_pages_created_at, :show_pages_updated_at,
                                 :restrict_theme, :body_width, :google_analytics,
                                 :per_page, :per_page_default, :status,
                                 {locale_ids: [], grouping_ids: []})
  end

  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end
