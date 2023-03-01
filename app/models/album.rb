class Album < ApplicationRecord
  include HasCategories
  include HasYoutubeUrl
  include HasSlug

  SLUG_PATTERN = '^[a-z0-9-]*[a-z]+[a-z0-9-]*$'

  weby_content_i18n :title, :text, required: :title

  belongs_to :site
  belongs_to :user

  has_one :cover_photo, -> { AlbumPhoto.cover }, class_name: 'AlbumPhoto', inverse_of: :album

  has_many :album_photos, dependent: :destroy
  has_and_belongs_to_many :album_tags

  before_validation :generate_slug

  validates :album_photos, length: {maximum: :max_photos}
  validates :slug, format: { with: Regexp.new(SLUG_PATTERN.gsub(/^\^/, '\A').gsub(/\$$/, '\z')) }
  validates :cover_photo, presence: true

  accepts_nested_attributes_for :cover_photo, reject_if: proc { |attributes| attributes["image"].blank? }

  after_save :refresh_photos_count!

  scope :published, -> { where(publish: true) }
  scope :by_user, ->(id) { where(user_id: id) }

  def real_updated_at
    i18n_updated = i18ns.sort_by{|i18n| i18n.updated_at }.last.updated_at
    updated_at > i18n_updated ? updated_at : i18n_updated
  end

  def to_param
    id.to_s
  end

  def refresh_photos_count!
    update_column(:photos_count, album_photos.count)
  end

  def get_cover_photo
    @_cover_photo ||= cover_photo ? cover_photo : album_photos.first
  end

  # tipos de busca
  # 0 = "termo1 termo2"
  # 1 = termo1 AND termo2
  # 2 = termo1 OR termo2
  scope :with_search, ->(param, search_type) {
    if param.present?
      fields = ['album_i18ns.title', 'album_i18ns.text', 'users.first_name']
      query, values = '', {}
      case search_type
      when 0
        query = fields.map { |field| "LOWER(#{field}) LIKE :param" }.join(' OR ')
        values[:param] = "%#{param.try(:downcase)}%"
      when 1, 2
        keywords = param.split(' ')
        query = fields.map do |field|
          "(#{
              keywords.each_with_index.map do |keyword, idx|
                values["key#{idx}".to_sym] = "%#{keyword.try(:downcase)}%"
                "LOWER(#{field}) LIKE :key#{idx}"
              end.join(search_type == 1 ? ' AND ' : ' OR ')
          })"
        end.join(' OR ')
      end
      includes(:user, :i18ns, :locales)
      .where(query, values)
      .references(:user, :i18ns)
    end
  }

  private

  def max_photos
    if site
      _extension = site.extensions.find_by(name: 'gallery')
      _limit = _extension&.photos_limit.to_i
      _limit > 0 ? _limit : 999999999
    else
      999999999
    end
  end
end
