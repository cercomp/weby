module Calendar
  class Event < ActiveRecord::Base
    include Trashable

    EVENT_TYPES = %w(regional national international)

    acts_as_taggable_on :categories

    weby_content_i18n :name, :information, :place, required: :name

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

    def to_param
      "#{id} #{name}".parameterize
    end

    def self.uniq_category_counts
      category_counts.each_with_object(Hash.new) do |j, hash|
        name = j.name.upcase
        if hash[name]
          hash[name].count += j.count
        else
          hash[name] = j
        end
        hash
      end.values
    end

    def self.as_fullcalendar_json events
      events.map do |event|
        {
          id: event.id,
          title: event.name,
          start: event.begin_at,
          end: event.end_at,
          url: Rails.application.routes.url_helpers.event_path(event),
          color: '#3a87ad',
          description: event.information
        }
      end
    end
  end
end
