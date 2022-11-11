class AlbumPhoto < ApplicationRecord

  has_attached_file :image,
  styles: {
    o: "original",
    t: "160x160#",
    f: "400x300"
  },
  original_style: :o,
  path: proc {
    Rails.env.production? ?
      '/up/:site_id/albums/:style/:basename.:extension'
      : ':rails_root/public:url'
  },
  url: Rails.env.production? ? ':s3_alias_url' : '/up/:site_id/albums/:style/:basename.:extension',
  convert_options: {
    o: "-quality 90",
    t: "-quality 80 -strip", #-crop 160x160+0+0 +repage
    f: "-quality 80 -strip"
  }

  belongs_to :album
  belongs_to :user

  def parent
    album
  end

  scope :cover, -> { where is_cover: true }

  validates_attachment_presence :image,
                                message: I18n.t('activerecord.errors.messages.attachment_presence'),
                                on: :create

  do_not_validate_attachment_file_type :image
end
