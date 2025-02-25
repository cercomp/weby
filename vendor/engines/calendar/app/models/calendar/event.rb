module Calendar
  class Event < Calendar::ApplicationRecord
    include Trashable
    include OwnRepository
    include HasSlug
    include HasCategories
    if ENV['ELASTICSEARCH_URL'].present?
      include Calendar::EventElastic
    end

    EVENT_TYPES = %w(regional national international)

    weby_content_i18n :name, :information, :place, required: [:name, :place]

    belongs_to :site
    belongs_to :user

    has_many :event_sites, foreign_key: :calendar_event_id, 
             class_name: "::Calendar::EventSite", 
             inverse_of: :event, 
             dependent: :destroy
    has_many :sites, through: :event_sites
    has_one :own_event_site, ->(this){ where(site_id: this.site_id) }, 
            class_name: "::Calendar::EventSite", 
            foreign_key: :calendar_event_id
    has_many :menu_items, as: :target, dependent: :nullify
    has_many :posts_repositories, as: :post, dependent: :destroy
    has_many :related_files, through: :posts_repositories, source: :repository

    validates :begin_at, presence: true

    accepts_nested_attributes_for :event_sites, allow_destroy: true

    scope :upcoming, -> { where(' (begin_at >= :time OR end_at >= :time)', time: Time.current) }
    scope :previous, -> { where(' (end_at < :time)', time: Time.current) }
    scope :originals, -> { where(shared: false) }
    scope :shared_only, -> { where(shared: true) }

    scope :with_search, ->(param, search_type) {
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

    def event_site_for(site)
      event_sites.detect{|es| es.site_id == site.id }
    end

    def title
      name
    end

    def sync_fields
      value = read_attribute(:sync_fields)
      return [] if value.nil? || value.empty?
      return value if value.is_a?(Array)
      
      begin
        YAML.load(value) || []
      rescue
        []
      end
    end
    
    def sync_fields=(value)
      value = [] if value.nil?
      write_attribute(:sync_fields, value.is_a?(Array) ? value : [])
    end
    
    def same_date?
      if end_at
        begin_at.to_date == end_at.to_date
      else
        true
      end
    end

    def same_date?
      if end_at
        begin_at.to_date == end_at.to_date
      else
        true
      end
    end

    def only_begin_date?
      end_at.blank?
    end

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['event'] if attrs.key? 'event'

      attrs.except!('id', 'type', '@type', 'created_at', 'updated_at', 'site_id')

      attrs['user_id'] = options[:user] unless User.unscoped.find_by(id: attrs['user_id'])
      attrs['repository_id'] = Import::Application::CONVAR["repository"]["#{attrs['repository_id']}"]
      attrs['i18ns'] = attrs['i18ns'].map do |i18n|
        i18n['information'] = i18n['information'].gsub(/\/up\/[0-9]+/) {|x| "/up/#{options[:site_id]}"} if i18n['information']
        self::I18ns.new(i18n.except('id', '@type', 'type', 'created_at', 'updated_at', 'calendar_event_id'))
      end
      attrs['category_list'] = attrs.delete('categories').to_a.map { |category| category['name'] }
      attrs['related_file_ids'] = attrs.delete('related_files').to_a.map {|repo| Import::Application::CONVAR["repository"]["#{repo['id']}"] }

      self.create!(attrs)
    end

    def self.as_fullcalendar_json events, admin_link=false
      helper = Rails.application.routes.url_helpers
      events.map do |event|
        {
          id: event.id,
          title: event.name,
          start: event.begin_at,
          end: event.end_at,
          url: admin_link ? helper.admin_event_path(event) : helper.event_path(event),
          color: '#3a87ad',
          allDay: false,
          description: event.information
        }
      end
    end

    def self.new_or_clone id, params={}
      if id.present?
        event = current_scope.find_by(id: id)
        if event
          return current_scope.new({
            repository_id: event.repository_id,
            begin_at: event.begin_at,
            end_at: event.end_at,
            kind: event.kind,
            category_list: event.category_list,
            email: event.email,
            url: event.url,
            related_file_ids: event.related_file_ids,
            i18ns_attributes: event.i18ns.map do |i18n|
              {
                locale: i18n.locale,
                name: i18n.name,
                place: i18n.place,
                information: i18n.information
              }
            end
          })
        end
      end
      #default
      current_scope.new(params)
    end

    ##search
    def self.get_events site, params
      return [] if site.blank?
      if ENV['ELASTICSEARCH_URL'].present?
        get_events_es site, params
      else
        get_events_db site, params
      end
    end

    def self.get_events_es site, params
      params[:sort_direction] = 'desc' if params[:sort_direction].blank?
      params[:page] = 1 if params[:page].blank?

      filters = [{
        term: {site_id: site.id}
      }]
      if params[:tags].present?
        filters << {terms: {categories: normalize_tags(params[:tags])}}
      end
      if params[:start] && params[:end]
        _start = Time.zone.parse(params[:start]).to_i
        _end = Time.zone.parse(params[:end]).end_of_day.to_i
        filters << {
          bool: {
            should: [
              {range: {begin_at: {gte: _start, lte: _end}}},
              {range: {end_at: {gte: _start, lte: _end}}},
              {bool: {
                must: [
                  {range: {begin_at: {lte: _start}}},
                  {range: {end_at: {gte: _end}}}
                ]
              }}
            ]
          }
        }
      end
      if params[:fetch_all]
        params[:per_page] = 10000 # Elasticsearch max results
        params[:page] = 1
      end
      result = Calendar::Event.perform_search(params[:search],
        filter: filters,
        per_page: params[:per_page],
        page: params[:page],
        sort: params[:sort_column],
        sort_direction: params[:sort_direction],
        search_type: params.fetch(:search_type, 1).to_i
      )
    end

    def self.get_events_db site, params
      params[:direction] ||= 'desc'
      params[:page] ||= 1
      # Vai ao banco por linha para recuperar
      # tags e locales
      events = site.events.
        with_search(params[:search], params.fetch(:search_type, 1).to_i).
        order(params[:sort_column] + ' ' + params[:sort_direction])

      events = events.page(params[:page]).per(params[:per_page]) unless params[:fetch_all]
      if params[:start] && params[:end]
        events = events.where('(begin_at between :start and :end_date) OR '\
                              '(end_at between :start and :end_date) OR '\
                              '(begin_at < :start AND end_at > :end_date)',
                              start: Time.zone.parse(params[:start]), end_date: Time.zone.parse(params[:end]).end_of_day)
      end
      events = events.tagged_with(normalize_tags(params[:tags]), any: true) if params[:tags].present?
      events
    end

    def share_with(target_site)
      return false if target_site == self.site
      return false if event_sites.exists?(site_id: target_site.id)
      
      event_site = event_sites.build(
        site_id: target_site.id,
        front: true
      )

      event_site.category_list = self.category_list if self.respond_to?(:category_list)
      
      event_site.save
    end
    
    private

    def self.normalize_tags tags
      ApplicationController.helpers.unescape_param(tags).split(',').map { |tag| tag.mb_chars.downcase.to_s }
    end

  end
end
