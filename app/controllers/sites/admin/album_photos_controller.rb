class Sites::Admin::AlbumPhotosController < ApplicationController
  before_action :require_user
  before_action :check_authorization
  before_action :find_album
  before_action :find_album_photo, only: [:update, :destroy]

  respond_to :html, :js, :json, :rss

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
    #@album = @album.in(params[:show_locale])
  end

  def create
    @album_photo = @album.album_photos.new(album_photo_params)
    @album_photo.user = current_user
    respond_with(:site_admin, @album, @album_photo) do |format|
      if @album_photo.save
        format.json do
          render json: { photo_album: @album_photo,
                         archive_errors: @album_photo.errors.messages.merge(@album_photo.image.errors),
                         message: t('successfully_created')},
                 content_type: check_accept_json
        end
        #record_activity('uploaded_album_photo', @album_photo)
      else
        format.json do
          render json: { errors: @album_photo.errors.full_messages }, status: 412,
                 content_type: check_accept_json
        end
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @album_photo.assign_attributes(album_photo_params)
      if @album_photo.save
        record_activity('updated_album_photo', @album_photo)
        render json: { photo_album: @album_photo,
                      archive_errors: @album_photo.errors.messages.merge(@album_photo.image.errors),
                      message: t('successfully_updated')},
          content_type: check_accept_json
      else
        render json: { photo_album: @album_photo,
                       errors: @album_photo.errors.full_messages }, status: 412,
          content_type: check_accept_json
      end
  end

  def destroy
    if @album_photo.destroy
      record_activity('deleted_album_photo', @album_photo)
      render json: { photo_album: @album_photo,
                    archive_errors: @album_photo.errors.messages.merge(@album_photo.image.errors),
                    message: t('successfully_destroyed')},
            content_type: check_accept_json
    else
      render json: { errors: @album_photo.errors.full_messages }, status: 412,
            content_type: check_accept_json
    end
  end

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

  def find_album_photo
    @album_photo = @album.album_photos.find_by id: params[:id]
  end

  def sort_column
    params[:sort] || 'album_photos.id'
  end

  def check_accept_json
    request.env['HTTP_ACCEPT'].include?('application/json') ?
      'application/json' :
      'text/plain'
  end

  def album_photo_params
    params.require(:album_photo).permit(:image, :description)
  end
end
