module Calendar
  class Event < ActiveRecord::Base
    include Trashable
    
    weby_content_i18n :name, :information, required: :name

    belongs_to :site
    belongs_to :user

    belongs_to :image, class_name: 'Repository', foreign_key: 'repository_id'

    has_many :menu_items, as: :target, dependent: :nullify
    has_many :posts_repositories, as: :post, dependent: :destroy
    has_many :related_files, through: :posts_repositories, source: :repository

    scope :upcoming, -> { where(' (begin_at >= :time OR end_at >= :time)', time: Time.now) }
    scope :previous, -> { where(' (end_at < :time)', time: Time.now) }


    scope :search, ->(param, search_type) {
      if param.present?
        fields = ['calendar_event_i18ns.name', 'calendar_event_i18ns.information', 'calendar_events.url']
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
        includes(:i18ns, :locales)
        .where(query, values)
        .references(:i18ns)
      end
    }
  end
end
