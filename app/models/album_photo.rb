class AlbumPhoto < ApplicationRecord
  attach_options = {
    styles: {
      o: "original",
      t: "200x200#",
      f: "600x450"
    },
    original_style: :o,
    path: proc {
      Rails.env.production? ?
        '/up/:site_id/albums/:album_id/:style/:basename.:extension'
        : ':rails_root/public:url'
    },
    url: Rails.env.production? ? ':s3_alias_url' : '/up/:site_id/albums/:album_id/:style/:basename.:extension',
    convert_options: {
      o: "-quality 80",
      t: "-quality 70 -strip",
      f: "-quality 70 -strip"
    }
  }

  if ENV['STORAGE_HOST_ALBUM'].present?
    region = ENV['STORAGE_REGION'].presence || 'us-east-1'
    is_aws = ENV['STORAGE_HOST_ALBUM'].to_s.include?('aws')

    attach_options.merge!({
      storage: :s3,
      s3_protocol: :https,
      s3_permissions: 'private',
      s3_region: region,
      s3_headers: {
        'Cache-Control' => 'public, s-maxage=31536000, maxage=15552000',
        'Expires' => 1.year.from_now.to_formatted_s(:rfc822).to_s
      },
      s3_credentials: {
        bucket: ENV['STORAGE_BUCKET_ALBUM'],
        access_key_id: ENV['STORAGE_ACCESS_KEY_ALBUM'],
        secret_access_key: ENV['STORAGE_ACCESS_SECRET_ALBUM']
      },
      s3_host_alias: is_aws ?
        "#{ENV['STORAGE_BUCKET_ALBUM']}.s3-#{region}.amazonaws.com" :
        "#{ENV['STORAGE_HOST_ALBUM']}/#{ENV['STORAGE_BUCKET_ALBUM']}",
      s3_options: {
        endpoint: "https://#{ENV['STORAGE_HOST_ALBUM']}",
        force_path_style: !is_aws
      }
    })
  end

  has_attached_file :image, attach_options

  # Correto: AlbumPhoto faz parte da coleção album_photos
  belongs_to :album, inverse_of: :album_photos
  belongs_to :user
  has_one :site, through: :album

  # Ordem: valida duplicidade → só depois define posição
  before_validation :check_duplicate_filename, on: :create
  before_create     :set_position

  after_save    :refresh_photos_count
  after_destroy :refresh_photos_count

  scope :cover, -> { where is_cover: true }

  validates_attachment_size :image, less_than: proc { |item| item.get_current_file_size_limit }
  validates_attachment_presence :image,
    message: I18n.t('activerecord.errors.messages.attachment_presence'),
    on: :create
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  validates :slug, uniqueness: { scope: :album_id, allow_blank: true }

  # ================= PUBLIC =================

  def parent
    album
  end

  def make_cover!
    AlbumPhoto.transaction do
      album.album_photos.update_all(is_cover: false)
      update!(is_cover: true)
    end
  end

  def generate_slug
    return unless slug.blank?

    key = "#{image_file_name.to_s.parameterize}#{Time.current.to_i.to_s.last(6)}#{rand(255)}"
    self.slug = Digest::MD5.hexdigest(key).last(24)
  end

  def set_position
    self.position ||= album.album_photos.maximum(:position).to_i + 1
  end

  def prev_photo
    album.album_photos.order(position: :desc).where('position < ?', position).first
  end

  def next_photo
    album.album_photos.order(position: :asc).where('position > ?', position).first
  end

  def get_current_file_size_limit
    lim = 107374182400
    if album&.site
      ext = album.site.extensions.find_by(name: 'gallery')
      lim = 1048576 if ext&.limit_photo_size.to_i == 1
    end
    lim
  end

  # ================= PRIVATE =================

  private

  def check_duplicate_filename
    return unless album && image_file_name.present?

    exists = album.album_photos
                  .where.not(id: id)
                  .find_by(image_file_name: image_file_name)

    return unless exists

    errors.add(:image_file_name,
               I18n.t('file_already_exists', value: image_file_name))

    throw :abort
  end

  def refresh_photos_count
    album&.refresh_photos_count!
  end
end
