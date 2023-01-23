class Sites::Admin::AlbumsController < ApplicationController
  include ActsToToggle

  before_action :require_user
  before_action :check_authorization
  before_action :find_album, only: [:show, :edit, :update, :photos]

  helper_method :sort_column

  respond_to :html, :js, :json, :rss

  def index
    @albums = current_site.albums.page(params[:page]).per(params[:per_page])
    respond_with(:site_admin, @albums) do |format|
      if params[:template]
        format.js { render "#{params[:template]}" }
        format.html { render partial: "#{params[:template]}", layout: false }
      end
    end
  end

  # def get_pages
  #   case params[:template]
  #   when 'tiny_mce'
  #     params[:per_page] = 7
  #   end
  #   params[:direction] ||= 'desc'
  #   # Vai ao banco por linha para recuperar
  #   # tags e locales
  #   pages = current_site.pages.includes(:user)
  #   if params[:template] == 'list_popup'
  #     pages = pages.published
  #   end
  #     pages.with_search(params[:search], 1) # 1 = busca com AND entre termos
  #     .order(sort_column + ' ' + sort_direction)
  #     .page(params[:page]).per(params[:per_page])
  # end
  # private :get_pages

  # def sort_column
  #   params[:sort] || 'pages.id'
  # end
  # private :sort_column

  def show
    @album = @album.in(params[:show_locale])
  end

  def new
    @album = current_site.albums.new(publish: true)
    @album.build_cover_photo
  end

  def edit
    @album.build_cover_photo if !@album.cover_photo
  end

  def photos
    @album_photo = AlbumPhoto.new
  end

  def create
    @album = current_site.albums.new(album_params)
    @album.user = current_user
    @album.save!
    record_activity('created_album', @album)
    respond_with(:photos, :site_admin, @album)
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @album.update(album_params)
    record_activity('updated_album', @album)
    respond_with(:site_admin, @album)
  end

  # # DELETE /pages/1
  # # DELETE /pages/1.json
  # def destroy
  #   @page = current_site.pages.unscoped.find(params[:id])
  #   if @page.trash
  #     if @page.persisted?
  #       record_activity('moved_page_to_recycle_bin', @page)
  #       flash[:success] = t('moved_page_to_recycle_bin')
  #     else
  #       record_activity('destroyed_page', @page)
  #       flash[:success] = t('successfully_deleted')
  #     end
  #   else
  #     flash[:error] = @page.errors.full_messages.join(', ')
  #   end

  #   redirect_to @page.persisted? ? site_admin_pages_path : recycle_bin_site_admin_pages_path
  # end

  # def recover
  #   @page = current_site.pages.trashed.find(params[:id])
  #   if @page.untrash
  #     flash[:success] = t('successfully_restored')
  #   end
  #   record_activity('restored_page', @page)
  #   redirect_back(fallback_location: recycle_bin_site_admin_pages_path)
  # end

  # def destroy_many
  #   pages = current_site.pages.where(id: params[:ids].split(',')).each do |page|
  #     if page.trash
  #       record_activity('moved_page_to_recycle_bin', page)
  #       flash[:success] = t('moved_page_to_recycle_bin')
  #     end
  #   end
  #   redirect_back(fallback_location: site_admin_pages_path)
  # end


  # def empty_bin
  #   if current_site.pages.trashed.destroy_all
  #     flash[:success] = t('successfully_deleted')
  #   end
  #   redirect_to main_app.recycle_bin_site_admin_pages_path
  # end

  private

  def sort_column
    params[:sort] || 'albums.id'
  end

  def album_params
    params.require(:album).permit(:publish, :slug, :category_list, :video_url,
                                 { i18ns_attributes: [:id, :locale_id, :title, :text, :_destroy], album_tag_ids: [], cover_photo_attributes: [:id, :image]})
  end
end
