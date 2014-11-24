module Calendar
  class Event < ActiveRecord::Base
    include Trashable
    include OwnRepository

    EVENT_TYPES = %w(regional national international)

    acts_as_taggable_on :categories

    weby_content_i18n :name, :information, :place, required: [:name, :place]

    belongs_to :site
    belongs_to :user

    has_many :menu_items, as: :target, dependent: :nullify
    has_many :posts_repositories, as: :post, dependent: :destroy
    has_many :related_files, through: :posts_repositories, source: :repository

    validates :begin_at, presence: true

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

    def title
      name
    end

    def to_param
      "#{id} #{name}".parameterize
    end

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['event'] if attrs.key? 'event'

      attrs.except!('id', 'type', 'created_at', 'updated_at', 'site_id')

      attrs['user_id'] = options[:user] unless User.unscoped.find_by(id: attrs['user_id'])
      attrs['repository_id'] = Import::Application::CONVAR["repository"]["#{attrs['repository_id']}"]
      attrs['i18ns'] = attrs['i18ns'].map do |i18n|
        i18n['information'] = i18n['information'].gsub(/\/up\/[0-9]+/) {|x| "/up/#{options[:site_id]}"} if i18n['information']
        self::I18ns.new(i18n.except('id', 'type', 'created_at', 'updated_at', 'calendar_event_id'))
      end
      attrs['category_list'] = attrs.delete('categories').to_a.map { |category| category['name'] }
      attrs['related_file_ids'] = attrs.delete('related_files').to_a.map {|repo| Import::Application::CONVAR["repository"]["#{repo['id']}"] }

      self.create!(attrs)
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
