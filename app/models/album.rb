class Album < ApplicationRecord
  include HasCategories

  weby_content_i18n :title, :text, required: :title

  belongs_to :site
  belongs_to :user

  has_one :cover_photo, -> { AlbumPhoto.cover }, class_name: 'AlbumPhoto'

  has_many :album_photos

  scope :published, -> { where(publish: true) }
  scope :by_user, ->(id) { where(user_id: id) }

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
end
