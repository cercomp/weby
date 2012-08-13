class AdminController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization
  before_filter :search_images, only: [:edit]

  respond_to :html, :xml, :js

  def index
  end

  def show
  end

  def edit
    load_images_themes
  end

  def update
    params[:site][:top_banner_id] ||= nil
    if @site.update_attributes(params[:site])
      flash[:success] = t("successfully_updated")
      redirect_to edit_site_admin_path(@site)
    else
      load_images_themes
      render :edit
    end

  end

  def destroy
  end

  private
  def search_images
    @images = @site.repositories.
      description_or_filename(params[:image_search]).
      content_file(["image", "flash"]).
      page(params[:page]).per(@site.per_page_default)
  end

  def load_images_themes
    @images = @site.repositories.
      content_file(["image", "x-shockwave-flash"]).
      description_or_filename(params[:image_search]).
      page(params[:page]).
      per(params[:per_page])

    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/sites.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/user_sessions.html.erb")]).each do |file|
       @themes << file.split("/")[-1].split(".")[0]
     end
  end
end
