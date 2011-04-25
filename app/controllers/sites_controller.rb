class SitesController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_authorization, :except => [:show, :index]
  respond_to :html, :xml

  helper_method :sort_column

  def index
    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction). # FIXME Ordenação não está funcionando
      page(params[:page]).
      per(params[:per_page])

    unless @sites
      flash[:warning] = (t"none_param", :param => t("page.one"))
    end
  end

  def show
    params[:controller] = 'pages'
    params[:action] = 'view'
    params[:site_id] = @site.name
    params[:id] = nil
    redirect_to  params
#    @site = Site.find_by_name(params[:id])
#    respond_with(@site)
  end

  def new
    @site = Site.new
    respond_with(@site)
  end

  def edit
    @repositories = Repository.search(params[:search], params[:page],["archive_content_type LIKE ?","image%"])
    #    @repositories = Repository.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 1 
    @site = Site.find_by_name(params[:id])
  end

  def create
    @site = Site.new(params[:site])
    @site.save
    respond_with(@site)
  end

  def update
    @site = Site.find_by_name(params[:id])
    if @site.update_attributes(params[:site])
      flash[:notice] = t"successfully_updated"
    end
    redirect_to edit_site_admin_path(@site, @site)
  end

  def destroy
    @site = Site.find_by_name(params[:id])
    @site.destroy
    respond_with(@site)
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end
