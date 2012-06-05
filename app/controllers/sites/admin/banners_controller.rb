class Sites::Admin::BannersController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  before_filter :repositories, :only => ['new', 'edit', 'create', 'update']
  before_filter :search_images, only: [:new, :edit, :create, :update]

  helper_method :sort_column

  respond_to :html, :xml, :js

  def index
    @banners = @site.banners.
      order(sort_column + " " + sort_direction).
      titles_or_texts_like(params[:search]).
      page(params[:page]).per(params[:per_page])

    unless @banners
      flash.now[:warning] = (t"none_param", :param => t("banner.one"))
    end
  end

  def show
    @banner = Banner.find(params[:id])
  end

  def new
    @banner = Banner.new
    @banner.new_tab = true
  end

  def edit
    @banner = Banner.find(params[:id])
  end

  def create
    @banner = Banner.new(params[:banner])
    @banner.user_id = @current_user.id
    if params[:submit_search]
      search_images
      render action: :edit
    end
    @banner.save
    respond_with(@site, :admin, @banner)
  end

  def update
    params[:banner][:repository_id] ||= nil
    @banner = Banner.find(params[:id])
    if params[:submit_search]
      @banner.attributes = params[:banner]
      search_images
    end
    @banner.update_attributes(params[:banner])
    respond_with(@site, :admin, @banner)
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy

    # TODO mensagem de banner removido com sucesso
    redirect_to(site_admin_banners_path(@site))
  end

  def toggle_field
    @banner = Banner.find(params[:id])
    if params[:field] 
      if @banner.update_attributes("#{params[:field]}" => (@banner[params[:field]] == 0 or not @banner[params[:field]] ? true : false))
        flash[:success] = t("successfully_updated")
      else
        flash[:warning] = t("error_updating_object")
      end
    end
    redirect_to :back
  end

  private
  def sort_column
    Banner.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def repositories
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).page(params[:page]).per(params[:per_page])
  end

  def search_images
    @images = @site.repositories.
      description_or_filename(params[:image_search]).
      content_file(["image", "flash"]).
      page(params[:page]).per(@site.per_page_default)
  end
end
