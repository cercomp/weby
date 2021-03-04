module Journal
  class News < Journal::ApplicationRecord
    include Trashable
    include OwnRepository

    weby_content_i18n :title, :summary, :text, required: :title

    STATUS_LIST = %w(draft review published)

    belongs_to :site, inverse_of: :own_news
    belongs_to :user

    has_many :views, as: :viewable
    has_many :menu_items, as: :target, dependent: :nullify
    has_many :posts_repositories, as: :post, dependent: :destroy
    has_many :related_files, through: :posts_repositories, source: :repository
    has_many :news_sites, foreign_key: :journal_news_id, class_name: "::Journal::NewsSite", inverse_of: :news, dependent: :destroy
    has_many :sites, through: :news_sites
    has_many :newsletter_histories, dependent: :destroy, class_name: "::Journal::NewsletterHistories"

    has_one :own_news_site, ->(this){ where(site_id: this.site_id) }, class_name: "::Journal::NewsSite", foreign_key: :journal_news_id

    # Validations
    validates :user_id, :site_id, :status, presence: true

    validate :validate_date

    scope :published, -> { where(status: 'published') }
    scope :review, -> { where(status: 'review') }
    scope :draft, -> { where(status: 'draft') }
    scope :by_user, ->(id) { where(user_id: id) }
    scope :available, -> { where('journal_news.date_begin_at is NULL OR journal_news.date_begin_at <= :time', time: Time.current) }
    scope :available_fronts, -> { available.front.where('journal_news.date_end_at is NULL OR journal_news.date_end_at > :time', time: Time.current) }

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
        includes(:user, :i18ns, :locales)
        .where(query, values)
        .references(:user, :i18ns)
      end
    }

    after_trash :reindex_news_site
    after_untrash :reindex_news_site

    def reindex_news_site
      own_news_site.reindex if own_news_site.respond_to?(:reindex)
    end
    private :reindex_news_site

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['news'] if attrs.key? 'news'
      attrs = attrs['own_news'] if attrs.key? 'own_news'

      id = attrs['id']
      attrs.except!('id', '@type', 'type', 'site_id') # 'created_at', 'updated_at'

      attrs['user_id'] = options[:user] unless User.unscoped.find_by(id: attrs['user_id'])
      repo_id = Import::Application::CONVAR["repository"]["#{attrs['repository_id']}"]
      repo = Repository.find(repo_id) if !repo_id.blank?
      attrs.except!('repository_id')
      if repo && repo.archive_content_type
        repo.image? ? attrs['repository_id'] = repo_id : attrs.except!('repository_id')
      end

      attrs['i18ns'] = attrs['i18ns'].map do |i18n|
        i18n['text'] = i18n['text'].gsub(/\/up\/[0-9]+/) {|x| "/up/#{options[:site_id]}"} if i18n['text']
        self::I18ns.new(i18n.except('id', '@type', 'type', 'journal_news_id')) # 'created_at', 'updated_at'
      end
                                                                               # 'created_at', 'updated_at'
      news_site_attrs = attrs.fetch('own_news_site', {}).except('id', 'type', '@type', 'journal_news_id', 'site_id').merge({
        site_id: options[:site_id]
      })
      news_site_attrs['category_list'] = news_site_attrs.delete('categories').to_a.map { |category| category['name'] }

      attrs['own_news_site'] = Journal::NewsSite.new(news_site_attrs)

      attrs['related_file_ids'] = attrs.delete('related_files').to_a.map {|repo| Import::Application::CONVAR["repository"]["#{repo['id']}"] }

      news = self.create!(attrs)
      if news.persisted?
        Import::Application::CONVAR["news"]["#{id}"] ||= "#{news.id}"
      end
    end

    def to_param
      "#{id} #{title}".parameterize
    end

    def published?
      status == 'published'
    end

    def link
      if url.blank?
        news_url(self, subdomain: self.site)
      else
        url
      end
    end

    def real_updated_at
      i18n_updated = i18ns.sort_by{|i18n| i18n.updated_at }.last.updated_at
      updated_at > i18n_updated ? updated_at : i18n_updated
    end

    def news_site_for site
      news_sites.detect{|ns| ns.site_id == site.id }
    end

    accepts_nested_attributes_for :news_sites, allow_destroy: true

    def self.new_or_clone id, params={}
      if id.present?
        site_id = current_scope.values.fetch(:where, {}).to_h['site_id']
        news_site = Journal::NewsSite.where(site_id: (site_id || -1)).find_by(id: id)
        if news_site && (news = news_site.news)
          news = current_scope.new({
            repository_id: news.repository_id,
            source: news.source,
            url: news.url,
            status: news.status,
            date_begin_at: news.date_begin_at,
            date_end_at: news.date_end_at,
            related_file_ids: news.related_file_ids,
            i18ns_attributes: news.i18ns.map do |i18n|
              {
                locale: i18n.locale,
                title: i18n.title,
                summary: i18n.summary,
                text: i18n.text
              }
            end
          })
          news.news_sites.build(site_id: news.site_id, category_list: news_site.category_list, front: news_site.front)
          return news
        end
      end
      #default
      news = current_scope.new(params)
      news.news_sites.build(site_id: news.site_id)
      news
    end

    ### Search
    def self.get_news site, params
      return [] if site.blank?
      if ENV['ELASTICSEARCH_URL'].present?
        get_news_es site, params
      else
        get_news_db site, params
      end
    end

    def self.get_news_es site, params
      params[:direction] = 'desc' if params[:direction].blank?
      params[:page] = 1 if params[:page].blank?

      filters = [{
        term: {site_id: site.id}
      }]
      filters << {term: {status: 'published'}}
      if params[:tags].present?
        filters << {terms: {categories: normalize_tags(params[:tags])}}
      end
      result = Journal::NewsSite.perform_search(params[:search],
        filter: filters,
        per_page: params[:per_page],
        page: params[:page],
        sort: params[:sort_column],
        sort_direction: params[:sort_direction],
        search_type: params.fetch(:search_type, 1).to_i
      )
    end

    def self.get_news_db site, params
      params[:direction] = 'desc' if params[:direction].blank?
      params[:page] = 1 if params[:page].blank?
      if params[:tags].present?
        result = site.news_sites.published.includes(:categories, news: [:image, :related_files, :site, :i18ns]).
          tagged_with(normalize_tags(params[:tags]), any: true).
          with_search(params[:search], params.fetch(:search_type, 1).to_i).
          order(params[:sort_column] + ' ' + params[:sort_direction]).
          page(params[:page]).per(params[:per_page])
      else
        result = site.news_sites.published.includes(:categories, news: [:image, :related_files, :site, :i18ns]).
          with_search(params[:search], params.fetch(:search_type, 1).to_i).
          order(params[:sort_column] + ' ' + params[:sort_direction]).
          page(params[:page]).per(params[:per_page])
      end
      result
    end

    private

    def self.normalize_tags tags
      ApplicationController.helpers.unescape_param(tags).split(',').map { |tag| tag.mb_chars.downcase.to_s }
    end

    def validate_date
      self.date_begin_at = Time.current if date_begin_at.blank?
    end
  end
end
