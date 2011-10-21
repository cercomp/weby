class BannersController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization
  before_filter :repositories, :only => ['new', 'edit', 'create', 'update']
  before_filter :search_images, only: [:new, :edit]

  helper_method :sort_column

  respond_to :html, :xml, :js

  def index
    @banners = @site.banners.except(:order).
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
  end

  def edit
    @banner = Banner.find(params[:id])
  end

  def create
    @banner = Banner.new(params[:banner])
    if params[:submit_search]
      search_images
      render action: :edit
    else
      @banner.save
      respond_with(@site, @banner)
    end
  end

  def update
    @banner = Banner.find(params[:id])

    if params[:submit_search]
      @banner.attributes = params[:banner]
      search_images
      render action: :edit
    else
      respond_to do |format|
        if @banner.update_attributes(params[:banner])
          format.html { redirect_to([@site, @banner], :notice => t("successfully_updated")) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @banner.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy

    respond_to do |format|
      format.html { redirect_to(site_banners_path(@site)) }
      format.xml  { head :ok }
    end
  end

  def toggle_field
    @banner = Banner.find(params[:id])
    if params[:field] 
      if @banner.update_attributes("#{params[:field]}" => (@banner[params[:field]] == 0 or not @banner[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:warning] = t"error_updating_object"
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
      description_or_filename(params[:search]).
      content_file("image").
      page(params[:page]).per(@site.per_page_default)
  end
end
