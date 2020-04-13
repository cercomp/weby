module Journal
  class NewsSite < Journal::ApplicationRecord
    belongs_to :site
    belongs_to :news, class_name: "::Journal::News", foreign_key: :journal_news_id

    acts_as_ordered_taggable_on :categories
    acts_as_multisite

    validate :validate_position

    scope :published, -> { joins(:news).where(journal_news: {status: 'published'}) }
    scope :front, -> { where(front: true) }
    scope :no_front, -> { where(front: false) }
    scope :available, -> { where('journal_news_sites.date_begin_at is NULL OR journal_news_sites.date_begin_at <= :time', time: Time.now) }
    scope :available_fronts, -> { front.where('journal_news_sites.date_end_at is NULL OR journal_news_sites.date_end_at > :time', time: Time.now) }

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

    # Elasticsearch
    searchkick settings: {
        analysis: {
          filter: {
            custom_edge_ngram: {
              type: 'edge_ngram',
              min_gram: 4,
              max_gram: 20
            }
          },
          analyzer: {
            title_index: {
              type: 'custom',
              tokenizer: 'standard',
              filter: ['lowercase', 'asciifolding', 'custom_edge_ngram']
            }
          }
        },
      },
      mappings: {
        properties: {
          site_id: {type: 'keyword', index: true},
          owner_site_id: {type: 'keyword', index: true},
          title_ptbr: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard'},
          summary_ptbr: {type: 'text', index: true, analyzer: 'standard'},
          text_ptbr: {type: 'text', index: true, analyzer: 'standard'},
          title_en: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard'},
          summary_en: {type: 'text', index: true, analyzer: 'standard'},
          text_en: {type: 'text', index: true, analyzer: 'standard'},
          title_es: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard'},
          summary_es: {type: 'text', index: true, analyzer: 'standard'},
          text_es: {type: 'text', index: true, analyzer: 'standard'},
          title_fr: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard'},
          summary_fr: {type: 'text', index: true, analyzer: 'standard'},
          text_fr: {type: 'text', index: true, analyzer: 'standard'},
          categories: {type: 'keyword', index: true},
          is_shared: {type: 'boolean', index: false},
          status: {type: 'keyword', index: true},
          user_id: {type: 'keyword', index: true},
          user_name: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard'}
        }
      }

    scope :search_import, -> { includes(:categories, {news: [:i18ns, :user]}) }

    def should_index?
      news && !news.is_trashed?
    end

    def search_data
      i18n_ptbr = news.i18n_in('pt-BR')
      i18n_en = news.i18n_in('en')
      i18n_es = news.i18n_in('es')
      i18n_fr = news.i18n_in('fr')
      {
        site_id: site_id,
        owner_site_id: news.site_id,
        title_ptbr: i18n_ptbr&.title,
        summary_ptbr: i18n_ptbr&.summary,
        text_ptbr: i18n_ptbr&.text,
        title_en: i18n_en&.title,
        summary_en: i18n_en&.summary,
        text_en: i18n_en&.text,
        title_es: i18n_es&.title,
        summary_es: i18n_es&.summary,
        text_es: i18n_es&.text,
        title_fr: i18n_fr&.title,
        summary_fr: i18n_fr&.summary,
        text_fr: i18n_fr&.text,
        categories: categories.map(&:name),
        is_shared: site_id == news.site_id,
        status: news.status,
        user_id: news.user_id,
        user_name: news.user.first_name
      }
    end

    def self.perform_search(term, opts={})
      locale = I18n.locale.to_s.downcase.gsub('-', '')
      query = if term.present?
        {
          multi_match: {
            query: term,
            fields: ["title_#{locale}", "summary_#{locale}", "text_#{locale}", "user_name"],
            operator: 'or'
          }
        }
      else
        {
          match_all: {}
        }
      end

      body = {
        query: {
          bool: {
            must: query
          }
        }
      }

      permitted_sort = {
        'best': '_score',
        'ig-growth':          {'ig_followers_change': 'desc'},
        'ig-max-likes':       {'ig_likes_per_post': 'desc'},
        'ig-mentions-unique': {'ig_mentions_unique': 'desc'},
        'tw-growth':          {'tw_followers_change': 'desc'},
        'tw-max-likes':       {'tw_likes_per_post': 'desc'},
        'tw-mentions-unique': {'tw_mentions_unique': 'desc'},
        'yt-growth':          {'yt_followers_change': 'desc'},
        'yt-max-views':       {'yt_views_per_video': 'desc'},
        'hyperank':           {'hyperank': {'order': 'asc', 'missing': '_last'}}
      }

      if opts[:sort] && permitted_sort.keys.include?(opts[:sort].to_sym)
        body[:sort] = permitted_sort[ opts[:sort].to_sym ]
      end

      if opts[:filter]
        body[:query][:bool][:filter] = opts[:filter]
      end

      if opts.has_key?(:limit) && !opts[:limit].nil?
        size = opts[:limit].to_i
        body[:size] = size

        if opts[:page].present?
          from = (opts[:page].to_i - 1) * size
          body[:from] = from
        end
      end

      self.search({
        body: body,
        debug: false,
        includes: [:categories, {news: :i18ns}]
      })
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

    def validate_date
      self.date_begin_at = Time.now.to_s if date_begin_at.blank?
    end
  end
end
