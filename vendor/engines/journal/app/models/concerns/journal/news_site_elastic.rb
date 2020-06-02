module Journal
  module NewsSiteElastic
    extend ActiveSupport::Concern

    included do

      searchkick settings: {
          analysis: {
            filter: {
              custom_edge_ngram: {
                type: 'edge_ngram',
                min_gram: 1,
                max_gram: 6
              }
            },
            analyzer: {
              title_index: {
                type: 'custom',
                tokenizer: 'standard',
                filter: ['lowercase', 'asciifolding', 'custom_edge_ngram']
              }
            },
            normalizer: {
              lowercase_normalizer: {
                type: 'custom',
                filter: ['lowercase', 'asciifolding']
              }
            }
          }
        },
        mappings: {
          properties: {
            site_id: {type: 'keyword', index: true},
            news_id: {type: 'keyword', index: false},
            owner_site_id: {type: 'keyword', index: true},
            title_ptbr: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
              fields: {
                raw: {type: 'text', analyzer: 'standard'}
              }
            },
            summary_ptbr: {type: 'text', index: true, analyzer: 'standard'},
            text_ptbr: {type: 'text', index: true, analyzer: 'standard'},
            title_en: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
              fields: {
                raw: {type: 'text', analyzer: 'standard'}
              }
            },
            summary_en: {type: 'text', index: true, analyzer: 'standard'},
            text_en: {type: 'text', index: true, analyzer: 'standard'},
            title_es: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
              fields: {
                raw: {type: 'text', analyzer: 'standard'}
              }
            },
            summary_es: {type: 'text', index: true, analyzer: 'standard'},
            text_es: {type: 'text', index: true, analyzer: 'standard'},
            title_fr: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
              fields: {
                raw: {type: 'text', analyzer: 'standard'}
              }
            },
            summary_fr: {type: 'text', index: true, analyzer: 'standard'},
            text_fr: {type: 'text', index: true, analyzer: 'standard'},
            categories: {type: 'keyword', index: true, normalizer: 'lowercase_normalizer'},
            is_shared: {type: 'boolean', index: false},
            news_created_at: {type: 'date', index: false},
            news_updated_at: {type: 'date', index: false},
            created_at: {type: 'date', index: false},
            updated_at: {type: 'date', index: false},
            front: {type: 'boolean', index: true},
            front_begin_at: {type: 'date', index: true},
            front_end_at: {type: 'date', index: true},
            status: {type: 'keyword', index: true},
            user_id: {type: 'keyword', index: true},
            user_name: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard'}
          }
        }

      scope :search_import, -> { includes(:categories, {news: [:i18ns, :user]}) }

      def self.perform_search(term, opts={})
        locale = I18n.locale.to_s.downcase.gsub('-', '')
        search_type = opts.has_key?(:search_type) ? opts[:search_type].to_i : 1
        fields = ["title_#{locale}", "title_#{locale}.raw", "summary_#{locale}", "text_#{locale}", "user_name"]
        # 0 = "termo1 termo2"
        # 1 = termo1 AND termo2
        # 2 = termo1 OR termo2
        query = if term.present?
          if search_type == 0
            {
              bool: {
                should: fields.map do |field|
                  {match_phrase: {field => term}}
                end
              }
            }
          else
            {
              multi_match: {
                query: term,
                fields: fields,
                operator: search_type == 1 ? 'and' : 'or'
              }
            }
          end
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
          'journal_news.id':    'news_id',
          'journal_news.created_at': 'news_created_at',
          'journal_news.updated_at': 'news_updated_at',
          'journal_news.title': "title_#{locale}"
        }

        if opts[:sort] && permitted_sort.keys.include?(opts[:sort].to_sym)
          body[:sort] = [{permitted_sort[opts[:sort].to_sym] => opts[:sort_direction]}]
        end

        if opts[:filter]
          body[:query][:bool][:filter] = opts[:filter]
        end

        if opts.has_key?(:per_page) && !opts[:per_page].nil?
          size = opts[:per_page].to_i
          body[:size] = size

          if opts[:page].present?
            from = (opts[:page].to_i - 1) * size
            body[:from] = from
          end
        end

        self.search({
          body: body,
          includes: [:categories, {news: :i18ns}],
          scope_results: ->(r) { r.joins(:news) },
          page: opts[:page],
          per_page: opts[:per_page].to_i
        })
      end

    end

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
        news_id: news.id,
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
        front: front,
        news_created_at: news.created_at.to_i,
        news_updated_at: news.updated_at.to_i,
        created_at: created_at.to_i,
        updated_at: updated_at.to_i,
        front_begin_at: news.date_begin_at.to_i > 0 ? news.date_begin_at.to_i : nil,
        front_end_at:   news.date_end_at.to_i > 0 ? news.date_end_at.to_i : nil,
        status: news.status,
        user_id: news.user_id,
        user_name: news.user.first_name
      }
    end

  end
end