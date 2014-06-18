class Admin::SitesController < Admin::BaseController
  before_action :set_resource, only: [:edit, :update]
  before_action :set_themes, only: [:new, :create, :edit, :update]

  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= current_settings.per_page_default

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + ' ' + sort_direction).
      page(params[:page]).
      per(params[:per_page])
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)

    if @site.save
      theme = ::Weby::Theme.new @site
      theme.populate
      record_activity('created_site', @site)
      redirect_to site_admin_components_url(subdomain: @site)
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
      redirect_to edit_admin_site_path(@site.id)
    else
      render :edit
    end
  end

  private

  def set_resource
    resource
  end

  def site_params
    params.require(:site).permit(:title, :top_banner_id, :name, :parent_id, :url,
                                 :domain, :description, :view_desc_pages, :theme,
                                 :body_width, :per_page, :per_page_default,
                                 {locale_ids: [], grouping_ids: []})
  end

  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def set_themes
    @themes = Weby::Themes.all
  end
end
