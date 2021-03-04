module PageElastic
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
          }
        }
      },
      mappings: {
        properties: {
          site_id: {type: 'keyword', index: true},
          title_ptbr: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
            fields: {
              raw: {type: 'text', analyzer: 'standard'}
            }
          },
          text_ptbr: {type: 'text', index: true, analyzer: 'standard'},
          title_en: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
            fields: {
              raw: {type: 'text', analyzer: 'standard'}
            }
          },
          text_en: {type: 'text', index: true, analyzer: 'standard'},
          title_es: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
            fields: {
              raw: {type: 'text', analyzer: 'standard'}
            }
          },
          text_es: {type: 'text', index: true, analyzer: 'standard'},
          title_fr: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
            fields: {
              raw: {type: 'text', analyzer: 'standard'}
            }
          },
          text_fr: {type: 'text', index: true, analyzer: 'standard'},
          created_at: {type: 'date', index: false},
          updated_at: {type: 'date', index: false},
          publish: {type: 'boolean', index: true},
          user_id: {type: 'keyword', index: true},
          user_name: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard'}
        }
      }

    scope :search_import, -> { includes(:i18ns, :user) }

    def self.perform_search(term, opts={})
      locale = I18n.locale.to_s.downcase.gsub('-', '')
      search_type = opts.has_key?(:search_type) ? opts[:search_type].to_i : 1
      fields = ["title_#{locale}", "title_#{locale}.raw", "text_#{locale}", "user_name"]
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
        'pages.id':    '_id',
        'pages.created_at': 'created_at',
        'pages.updated_at': 'updated_at',
        'pages.title': "title_#{locale}"
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
        includes: [:i18ns, :user],
        #scope_results: ->(r) { r.joins(:news) },
        page: opts[:page],
        per_page: opts[:per_page].to_i
      })
    end

  end

  def should_index?
    !is_trashed? && publish?
  end

  def search_data
    i18n_ptbr = i18n_in('pt-BR')
    i18n_en =   i18n_in('en')
    i18n_es =   i18n_in('es')
    i18n_fr =   i18n_in('fr')
    {
      site_id: site_id,
      title_ptbr: i18n_ptbr&.title,
      text_ptbr: i18n_ptbr&.text,
      title_en: i18n_en&.title,
      text_en: i18n_en&.text,
      title_es: i18n_es&.title,
      text_es: i18n_es&.text,
      title_fr: i18n_fr&.title,
      text_fr: i18n_fr&.text,
      created_at: created_at.to_i,
      updated_at: updated_at.to_i,
      publish: publish?,
      user_id: user_id,
      user_name: user.first_name
    }
  end

end
