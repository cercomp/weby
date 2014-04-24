class Sites::Admin::BannersController < ApplicationController
  include ActsToToggle

  before_filter :require_user
  before_filter :check_authorization
  before_filter :search_images, only: [:new, :edit, :create, :update]

  helper_method :sort_column

  respond_to :html, :xml, :js

  def index
    sort = sort_column == "id" ?  " " : (sort_column + " " + sort_direction + ", ")
    @banners = Banner.unscoped.where(site_id: current_site).
     order(sort + "position ASC").
     titles_or_texts_like(params[:search]).
     page(params[:page]).per(params[:per_page])
  end

  def show
    @banner = current_site.banners.find(params[:id])
  end

  def new
    @banner = current_site.banners.new
    #@banner.new_tab = true
  end

  def edit
    @banner = current_site.banners.find(params[:id])
  end

  def create
    @banner = current_site.banners.new(params[:banner])
    @banner.user_id = @current_user.id
    if params[:submit_search]
      search_images
      render action: :edit
    end
    if @banner.save
      record_activity("created_banner", @banner)
    end
    respond_with(:site_admin, @banner)
  end

  def update
    @banner = current_site.banners.find(params[:id])
    if params[:submit_search]
      @banner.attributes = params[:banner]
      search_images
    end
    if @banner.update_attributes(params[:banner])
      record_activity("updated_banner", @banner)
    end
    respond_with(:site_admin, @banner)
  end

  def destroy
    @banner = current_site.banners.find(params[:id])
    if @banner.destroy
      record_activity("destroyed_banner", @banner)
      flash[:success] = t("destroyed_param", :param => @banner.title)
    end

    redirect_to(site_admin_banners_path())
  end

  private
  def sort_column
    Banner.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def search_images
    @images = current_site.repositories.
      description_or_filename(params[:image_search]).
      content_file(["image", "flash"]).
      page(params[:page]).per(current_site.per_page_default)
  end
end
