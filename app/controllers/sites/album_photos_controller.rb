require 'open-uri'

class Sites::AlbumPhotosController < ApplicationController
  layout :choose_layout

  before_action :find_album, only: [:show, :download]

  respond_to :html, :js, :json

  def show
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user && !current_user&.is_admin?
    @album_photo = @album.album_photos.find_by(id: params[:id]) || @album.album_photos.find_by(slug: params[:id])
    raise ActiveRecord::RecordNotFound unless @album_photo

    all_photos = @album.album_photos.order(:position, :id).to_a
    @total_photos = all_photos.size
    @current_photo_index = (all_photos.index(@album_photo) || 0) + 1
  end

  def download
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user && !current_user&.is_admin?
    @album_photo = @album.album_photos.find_by(id: params[:id]) || @album.album_photos.find_by(slug: params[:id])
    raise ActiveRecord::RecordNotFound unless @album_photo

    image = @album_photo.image
    filename = image.original_filename || "foto_#{@album_photo.id}.jpg"

    if image.options[:storage] == :s3
      # Para S3, lê o arquivo da URL e envia os dados
      data = URI.open(image.url(:o))
      send_data data.read, filename: filename, disposition: 'attachment', type: image.content_type
    else
      # Para arquivos locais, envia o arquivo diretamente
      file_path = image.path(:o)
      if File.exist?(file_path)
        send_file file_path, filename: filename, disposition: 'attachment', type: image.content_type
      else
        # Se o arquivo não for encontrado, retorna um erro 404
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  private

  def find_album
    raise ActiveRecord::RecordNotFound unless current_site

    _id = params[:album_id] || params[:id]
    raise ActiveRecord::RecordNotFound unless _id.present?

    @album = current_site.albums.find_by(slug: _id) || current_site.albums.find_by(id: _id)
    raise ActiveRecord::RecordNotFound unless @album
  end
end

