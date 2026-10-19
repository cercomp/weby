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
    # Validação específica para limite de upload (100 fotos por vez)
    # Não usar a validação do modelo que limita o total do álbum
    max_photos_per_upload = 100

    # Contar quantas fotos estão sendo enviadas nesta sessão de upload
    # Como cada foto é enviada individualmente via AJAX, verificamos quantas
    # foram enviadas recentemente (nos últimos 5 minutos)
    recent_photos_count = @album.album_photos
                                .where('created_at > ?', 5.minutes.ago)
                                .where(user: current_user)
                                .count

    Rails.logger.info "=== ALBUM PHOTO UPLOAD DEBUG ==="
    Rails.logger.info "Recent photos count (last 5 min): #{recent_photos_count}"
    Rails.logger.info "Max per upload: #{max_photos_per_upload}"
    Rails.logger.info "Album ID: #{@album.id}"
    Rails.logger.info "User ID: #{current_user.id}"

    if recent_photos_count >= max_photos_per_upload
      render json: {
        errors: ["Limite de #{max_photos_per_upload} fotos por upload atingido. Aguarde alguns minutos antes de fazer um novo upload."]
      }, status: 412, content_type: check_accept_json
      return
    end

    @album_photo = @album.album_photos.new(album_photo_params)
    @album_photo.user = current_user

    # Pular validação de limite total do álbum durante upload individual
    @album.skip_photos_limit_validation = true

    # Validar somente a foto individual, não o álbum completo
    if @album_photo.save
      render json: { photo_album: @album_photo,
                      archive_errors: @album_photo.errors.messages,
                      html: render_to_string(partial: '/sites/admin/albums/photo_card', formats: [:html], locals: {photo: @album_photo}),
                      message: t('successfully_created')},
              content_type: check_accept_json
      #record_activity('uploaded_album_photo', @album_photo)
    else
      _msg = @album_photo.errors.full_messages
      render json: { errors:  _msg}, status: 412,
              content_type: check_accept_json
    end
  end

  def update
    if (params[:make_cover] ? @album_photo.make_cover! : @album_photo.update(album_photo_params))
      record_activity('updated_album_photo', @album_photo)
      render json: { photo_album: @album_photo,
                    html: render_to_string(partial: '/sites/admin/albums/photo_card', formats: [:html], locals: {photo: @album_photo}),
                    archive_errors: @album_photo.errors.messages, #.merge(@album_photo.image.errors)
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
                    archive_errors: @album_photo.errors.messages, #.merge(@album_photo.image.errors)
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
