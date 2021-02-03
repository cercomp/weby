
module Calendar
  module EventElastic
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
            name_ptbr: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
              fields: {
                raw: {type: 'text', analyzer: 'standard'}
              }
            },
            place_ptbr: {type: 'text', index: true, analyzer: 'standard'},
            information_ptbr: {type: 'text', index: true, analyzer: 'standard'},
            name_en: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
              fields: {
                raw: {type: 'text', analyzer: 'standard'}
              }
            },
            place_en: {type: 'text', index: true, analyzer: 'standard'},
            information_en: {type: 'text', index: true, analyzer: 'standard'},
            name_es: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
              fields: {
                raw: {type: 'text', analyzer: 'standard'}
              }
            },
            place_es: {type: 'text', index: true, analyzer: 'standard'},
            information_es: {type: 'text', index: true, analyzer: 'standard'},
            name_fr: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard',
              fields: {
                raw: {type: 'text', analyzer: 'standard'}
              }
            },
            place_fr: {type: 'text', index: true, analyzer: 'standard'},
            information_fr: {type: 'text', index: true, analyzer: 'standard'},
            categories: {type: 'keyword', index: true, normalizer: 'lowercase_normalizer'},
            begin_at: {type: 'date', index: true},
            end_at: {type: 'date', index: true},
            created_at: {type: 'date', index: false},
            updated_at: {type: 'date', index: false},
            kind: {type: 'keyword', index: true},
            user_id: {type: 'keyword', index: true},
            user_name: {type: 'text', index: true, analyzer: 'title_index', search_analyzer: 'standard'}
          }
        }

      scope :search_import, -> { includes(:categories, :i18ns, :user) }

      def self.perform_search(term, opts={})
        locale = I18n.locale.to_s.downcase.gsub('-', '')
        search_type = opts.has_key?(:search_type) ? opts[:search_type].to_i : 1
        fields = ["name_#{locale}", "name_#{locale}.raw", "place_#{locale}", "information_#{locale}", "user_name"]
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
          'calendar_events.id':    '_id',
          'calendar_events.created_at': 'created_at',
          'calendar_events.updated_at': 'updated_at',
          'calendar_events.begin_at': 'begin_at',
          'calendar_events.end_at': 'end_at',
          'calendar_events.name': "name_#{locale}"
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
          includes: [:categories, :i18ns, :user],
          #scope_results: ->(r) { r.joins(:news) },
          page: opts[:page],
          per_page: opts[:per_page].to_i
        })
      end

    end

    def should_index?
      !is_trashed?
    end

    def search_data
      i18n_ptbr = i18n_in('pt-BR')
      i18n_en = i18n_in('en')
      i18n_es = i18n_in('es')
      i18n_fr = i18n_in('fr')
      {
        site_id: site_id,
        name_ptbr: i18n_ptbr&.name,
        place_ptbr: i18n_ptbr&.place,
        information_ptbr: i18n_ptbr&.information,
        name_en: i18n_en&.name,
        place_en: i18n_en&.place,
        information_en: i18n_en&.information,
        name_es: i18n_es&.name,
        place_es: i18n_es&.place,
        information_es: i18n_es&.information,
        name_fr: i18n_fr&.name,
        place_fr: i18n_fr&.place,
        information_fr: i18n_fr&.information,
        categories: categories.map(&:name),
        created_at: created_at.to_i,
        updated_at: updated_at.to_i,
        begin_at: begin_at.to_i,
        end_at: end_at.to_i,
        kind: kind,
        user_id: user_id,
        user_name: user.first_name
      }
    end

  end
end