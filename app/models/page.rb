class Page < ApplicationRecord
  include Trashable
  if ENV['ELASTICSEARCH_URL'].present?
    include PageElastic
  end

  weby_content_i18n :title, :text, required: :title

  acts_as_multisite

  belongs_to :site
  belongs_to :user

  has_many :views, as: :viewable, dependent: :delete_all
  has_many :menu_items, as: :target, dependent: :nullify
  has_many :posts_repositories, as: :post, dependent: :destroy
  has_many :related_files, through: :posts_repositories, source: :repository

  # Validations
  validates :user_id, :site_id, presence: true
  validate :should_be_own_files

  scope :published, -> { where(publish: true) }

  scope :by_user, ->(id) { where(user_id: id) }

  # tipos de busca
  # 0 = "termo1 termo2"
  # 1 = termo1 AND termo2
  # 2 = termo1 OR termo2
  scope :with_search, ->(param, search_type) {
    if param.present?
      fields = ['page_i18ns.title', 'page_i18ns.text', 'users.first_name']
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

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['page'] if attrs.key? 'page'

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', '@type')

    attrs['user_id'] = options[:user] unless User.unscoped.find_by(id: attrs['user_id'])

    attrs['i18ns'] = attrs['i18ns'].map do |i18n|
      i18n['text'] = i18n['text'].gsub(/\/up\/[0-9]+/) { |x| "/up/#{options[:site_id]}" } if i18n['text']
      self::I18ns.new(i18n.except('id', 'type', '@type', 'created_at', 'updated_at', 'page_id'))
    end
    attrs['related_file_ids'] = attrs.delete('related_files').to_a.map { |repo| Import::Application::CONVAR["repository"]["#{repo['id']}"] }

    self.create!(attrs)
  end

  def to_param
    "#{id} #{title}".parameterize
  end

  def real_updated_at
    i18n_updated = i18ns.sort_by{|i18n| i18n.updated_at }.last.updated_at
    updated_at > i18n_updated ? updated_at : i18n_updated
  end

  def self.new_or_clone id, params={}
    if id.present?
      page = current_scope.find_by(id: id)
      if page
        return current_scope.new(
          publish: page.publish,
          related_file_ids: page.related_file_ids,
          i18ns_attributes: page.i18ns.map do |i18n|
            {
              locale: i18n.locale,
              title: i18n.title,
              text: i18n.text
            }
          end
        )
      end
    end
    #default
    current_scope.new(params)
  end

  ## Search
  def self.get_pages site, params
    return [] if site.blank?
    if ENV['ELASTICSEARCH_URL'].present?
      get_pages_es site, params
    else
      get_pages_db site, params
    end
  end


  def self.get_pages_es site, params
    params[:direction] = 'desc' if params[:direction].blank?
    params[:page] = 1 if params[:page].blank?

    filters = [{
      term: {site_id: site.id}
    }]
    filters << {term: {publish: true}}
    result = Page.perform_search(params[:search],
      filter: filters,
      per_page: params[:per_page],
      page: params[:page],
      sort: params[:sort_column],
      sort_direction: params[:sort_direction],
      search_type: params.fetch(:search_type, 1).to_i
    )
  end

  def self.get_pages_db site, params
    params[:direction] ||= 'desc'

    pages = site.pages.published.
      with_search(params[:search], params.fetch(:search_type, 1).to_i).
      order(params[:sort_column] + ' ' + params[:sort_direction]).
      page(params[:page]).per(params[:per_page])
  end

  private

  def should_be_own_files
    error_message = I18n.t('should_be_own_files')
    errors.add(:related_files, error_message) unless own_files?
  end

  def own_files?
    related_files.each do |file|
      return false if file.site_id != site.id
    end
    true
  end
end
