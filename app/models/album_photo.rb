class AlbumPhoto < ApplicationRecord

  attach_options = {
    styles: {
      o: "original",
      t: "160x160#",
      f: "400x300"
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
      t: "-quality 70 -strip", #-crop 160x160+0+0 +repage
      f: "-quality 70 -strip"
    }
  }
  if ENV['STORAGE_HOST_ALBUM'].present?
    is_aws = ENV['STORAGE_HOST_ALBUM'].to_s.include?('aws')
    attach_options.merge!({
      s3_credentials: {
        bucket: ENV['STORAGE_BUCKET_ALBUM'],
        access_key_id: ENV['STORAGE_ACCESS_KEY_ALBUM'],
        secret_access_key: ENV['STORAGE_ACCESS_SECRET_ALBUM']
      },
      s3_host_alias: is_aws ? "#{ENV['STORAGE_BUCKET_ALBUM']}.s3-#{region}.amazonaws.com" : "#{ENV['STORAGE_HOST_ALBUM']}/#{ENV['STORAGE_BUCKET_ALBUM']}",
      s3_options: {
        endpoint: "https://#{ENV['STORAGE_HOST_ALBUM']}", # for aws-sdk
        force_path_style: !is_aws # for aws-sdk (required for minio)
      }
    })
  end

  has_attached_file :image, attach_options

  belongs_to :album
  belongs_to :user

  after_save :refresh_photos_count
  after_destroy :refresh_photos_count

  scope :cover, -> { where is_cover: true }

  validates_attachment_presence :image,
                                message: I18n.t('activerecord.errors.messages.attachment_presence'),
                                on: :create

  #do_not_validate_attachment_file_type :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  validate :unique_image_file_name

  def parent
    album
  end

  def make_cover!
    AlbumPhoto.transaction do
      parent.album_photos.update_all(is_cover: false)
      self.update!(is_cover: true)
    end
  end

  private

  def unique_image_file_name
    check_filename = album.album_photos.where.not(id: id).find_by(image_file_name: image_file_name)
    errors.add(:image_file_name, I18n.t('file_already_exists', value: check_filename.image_file_name)) if check_filename.present?
  end

  def refresh_photos_count
    album&.refresh_photos_count!
  end
end
