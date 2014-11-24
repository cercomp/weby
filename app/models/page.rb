class Page < ActiveRecord::Base
  include Trashable

  weby_content_i18n :title, :text, required: :title

  acts_as_multisite

  belongs_to :site
  belongs_to :user

  has_many :views, as: :viewable
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
  scope :search, ->(param, search_type) {
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

    attrs.except!('id', 'created_at', 'updated_at', 'site_id')

    attrs['user_id'] = options[:user] unless User.unscoped.find_by(id: attrs['user_id'])
    
    attrs['i18ns'] = attrs['i18ns'].map do |i18n|
      i18n['text'] = i18n['text'].gsub(/\/up\/[0-9]+/) {|x| "/up/#{options[:site_id]}"} if i18n['text']
      self::I18ns.new(i18n.except('id', 'type', 'created_at', 'updated_at', 'page_id'))
    end
    attrs['related_file_ids'] = attrs.delete('related_files').to_a.map {|repo| Import::Application::CONVAR["repository"]["#{repo['id']}"] }

    self.create!(attrs)
  end

  def to_param
    "#{id} #{title}".parameterize
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
