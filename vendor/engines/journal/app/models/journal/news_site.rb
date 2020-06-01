module Journal
  class NewsSite < Journal::ApplicationRecord
    if ENV['ELASTICSEARCH_URL'].present?
      include Journal::NewsSiteElastic
    end

    belongs_to :site
    belongs_to :news, class_name: "::Journal::News", foreign_key: :journal_news_id

    acts_as_ordered_taggable_on :categories
    acts_as_multisite

    validate :validate_position

    scope :published, -> { joins(:news).where(journal_news: {status: 'published'}) }
    scope :front, -> { where(front: true) }
    scope :no_front, -> { where(front: false) }
    scope :available, -> { joins(:news).where('journal_news.date_begin_at is NULL OR journal_news.date_begin_at <= :time', time: Time.current) }
    scope :available_fronts, -> { available.front.joins(:news).where('journal_news.date_end_at is NULL OR journal_news.date_end_at > :time', time: Time.current) }

    # tipos de busca
    # 0 = "termo1 termo2"
    # 1 = termo1 AND termo2
    # 2 = termo1 OR termo2
    scope :with_search, ->(param, search_type) {
      if param.present?
        fields = ['journal_news_i18ns.title', 'journal_news_i18ns.summary', 'journal_news_i18ns.text',
                  'users.first_name']
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
        includes(news: [:user, :i18ns])
        .where(query, values)
        .references(news: [:user, :i18ns])
      end
    }

    def category_list_before_type_cast
      category_list.to_s
    end

    private

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['news-site'] if attrs.key? 'news-site'
      attrs['category_list'] = attrs.delete('categories').to_a.map { |category| category['name'] }
      attrs.except!('id', '@type', 'type', 'site_id') # 'created_at', 'updated_at'
      attrs['journal_news_id'] = Import::Application::CONVAR["news"]["#{attrs['journal_news_id']}"]

      self.create!(attrs) if attrs['journal_news_id']
    end

    def validate_position
      self.position = last_front_position + 1 if self.position.nil?
#      self.position = 0 if self.position.nil?
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

    def last_front_position
      @news_site = Journal::NewsSite.where(site: self.site_id).front
      @news_site.maximum(:position).to_i
    end

  end
end
