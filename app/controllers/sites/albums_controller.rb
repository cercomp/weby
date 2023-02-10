class Sites::AlbumsController < ApplicationController
  include CheckSlug

  layout :choose_layout

  helper_method :sort_column
  before_action :check_current_site, :load_extension
  before_action :find_album, only: [:show, :generate]

  respond_to :html, :js, :json

  def index
    # desc_default_direction
    @albums = get_albums
    respond_with(@albums) do |format|
      format.json { render json: @albums, root: 'albums', meta: { total: @albums.total_count } }
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if !@album.publish && @album.user != current_user
    @photos = @album.album_photos.order(:position).page(params[:page]).per(50)
    if request.path != site_album_path(@album)
      redirect_to site_album_path(@album), status: :moved_permanently
      return
    end
  end

  def generate
    require 'zip/zip'
    require 'find'
    require 'fileutils'

    dir = "tmp/#{@album.id}"
    Dir.mkdir("#{dir}") unless Dir.exist?("#{dir}")

    FileUtils.rm_r Dir.glob("#{dir}/*")

    zipname = "album_#{@album.title}_#{Time.now.strftime('%d-%m-%Y')}.zip"
    zip_dir = Rails.root.join(dir, zipname)
    Zip::ZipFile.open(zip_dir, Zip::ZipFile::CREATE) do |zipfile|
      read_files_for_zip(current_site).each do |file, entry_path|
        begin
          if file.is_a?(String)
            zipfile.add(entry_path, file) if entry_path
          elsif file.is_a?(Aws::S3::Object)
            zipfile.get_output_stream(entry_path) do |f|
              f.write(file.get.body.read)
            end
          end
        rescue Zip::ZipEntryExistsError
        end
      end
    end

    zip_data = File.read("#{dir}/#{zipname}")
    send_data(zip_data, type: 'application/zip', filename: zipname)
  end

  private

  def sort_column
    params[:sort] || 'albums.id'
  end

  def get_albums
    params[:direction] ||= 'desc'

    find_album_tag
    (@album_tag || current_site).albums.
      with_search(params[:search], params.fetch(:search_type, 1).to_i).
      order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(params[:per_page])
  end

  def find_album_tag
    if params[:album_tag].present?
      @album_tag = if params[:album_tag].match(/^\d+$/)
        current_site.album_tags.find(params[:album_tag])
      else
        current_site.album_tags.find_by(slug: params[:album_tag])
      end
    end
  end

  def read_files_for_zip site
    if ENV['STORAGE_HOST_ALBUM'].present?
      s3 = Aws::S3::Resource.new(
        credentials: Aws::Credentials.new(ENV['STORAGE_ACCESS_KEY_ALBUM'], ENV['STORAGE_ACCESS_SECRET_ALBUM']),
        region: 'us-east-1',
        endpoint: "https://#{ENV['STORAGE_HOST_ALBUM']}",
        force_path_style: true
      )
      bucket = s3.bucket(ENV['STORAGE_BUCKET_ALBUM'])
      prefix = "up/#{site.id}/albums/#{@album.id}/o"
      bucket.objects(prefix: prefix).map do |obj|
        file = bucket.object(obj.key)
        [file, obj.key.gsub(prefix, 'album/')]
      end
    elsif ENV['STORAGE_HOST'].present?
      s3 = Aws::S3::Resource.new(
        credentials: Aws::Credentials.new(ENV['STORAGE_ACCESS_KEY'], ENV['STORAGE_ACCESS_SECRET']),
        region: 'us-east-1',
        endpoint: "https://#{ENV['STORAGE_HOST']}",
        force_path_style: true
      )
      bucket = s3.bucket(ENV['STORAGE_BUCKET'])
      prefix = "up/#{site.id}/albums/#{@album.id}/o"
      bucket.objects(prefix: prefix).map do |obj|
        file = bucket.object(obj.key)
        [file, obj.key.gsub(prefix, 'album/')]
      end
    else
      repository = "public/up/#{site.id}/albums/#{@album.id}/o"
      Find.find(repository).map do |path|
        Find.prune if File.basename(path)[0] == '.'
        dest = /#{repository}\/(\w.*)/.match(path)
        [path, dest ? "album/#{dest[1]}" : nil]
      end
    end
  end

  def load_extension
    @extension = current_site.extensions.find_by(name: 'gallery')
  end

  def check_current_site
    render_404 unless current_site
  end
end
