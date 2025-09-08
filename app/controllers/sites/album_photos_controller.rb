require 'open-uri'

class Sites::AlbumPhotosController < ApplicationController
  layout :choose_layout

  before_action :find_album, only: [:show, :download]

  respond_to :html, :js, :json

  def show
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
    @album_photo = @album.album_photos.find(params[:id])
  end

  def download
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
    @album_photo = @album.album_photos.find(params[:id])

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
    site = if request.subdomain.present?
      Site.find_by(name: request.subdomain)
    else
      Site.first
    end
    raise ActiveRecord::RecordNotFound unless site
    @album = site.albums.find_by(slug: params[:album_id])
  end

  def choose_layout
    # Lógica para escolher o layout
  end
end
