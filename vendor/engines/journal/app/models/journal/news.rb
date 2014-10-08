module Journal
  class News < ActiveRecord::Base
    include Trashable

    weby_content_i18n :title, :summary, :text, required: :title

    acts_as_taggable_on :categories
    acts_as_multisite

    belongs_to :site
    belongs_to :user
    belongs_to :image, class_name: 'Repository', foreign_key: 'repository_id'
    
    has_many :views, as: :viewable
    has_many :menu_items, as: :target, dependent: :nullify
    has_many :posts_repositories, as: :post, dependent: :destroy
    has_many :related_files, through: :posts_repositories, source: :repository

    # Validations
    validates :user_id, :site_id, presence: true
    
    validate :validate_date
    validate :should_be_image
    validate :should_be_own_image
    validate :should_be_own_files

    scope :published, -> { where(status: 'published') }
    scope :front, -> { where(front: true) }
    scope :no_front, -> { where(front: false) }
    scope :by_user, ->(id) { where(user_id: id) }

    scope :available, -> { where('date_begin_at is NULL OR date_begin_at <= :time', time: Time.now).published }
    scope :available_fronts, -> { front.available.where('date_end_at is NULL OR date_end_at > :time', time: Time.now) }

    # tipos de busca
    # 0 = "termo1 termo2"
    # 1 = termo1 AND termo2
    # 2 = termo1 OR termo2
    scope :search, ->(param, search_type) {
      if param.present?
        fields = ['journal_news_i18ns.title', 'journal_news_i18ns.summary', 'journal_news_i18ns.text',
                  'users.first_name', 'tags.name']
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
        includes(:user, :categories, :i18ns, :locales)
        .where(query, values)
        .references(:user, :categories, :i18ns)
      end
    }

#    before_trash do
#      if published?
#        errors[:base] << I18n.t('cannot_destroy_a_published_page')
#        false
#      else
#        true
#      end
#    end

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['news'] if attrs.key? 'news'

      attrs.except!('id', 'created_at', 'updated_at', 'site_id')

      attrs['user_id'] = options[:user] unless User.unscoped.find_by_id(attrs['user_id'])
      attrs['repository_id'] = ''

      attrs['i18ns'] = attrs['i18ns'].map { |i18n| self::I18ns.new(i18n.except('id', 'created_at', 'updated_at', 'news_id')) }

      self.create!(attrs)
    end

    def to_param
      "#{id} #{title}".parameterize
    end

    def published?
      status == 'published'
    end

    def image=(file)
      return self.repository_id = file.id if file.is_a?(Repository)
      self.repository_id = file
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

    private

    def validate_date
      self.date_begin_at = Time.now.to_s if date_begin_at.blank?
    end

    def should_be_image
      return unless image
      error_message = I18n.t('should_be_image')
      errors.add(:image, error_message) unless is_image?
    end

    def should_be_own_image
      return unless image
      error_message = I18n.t('should_be_own_image')
      errors.add(:image, error_message) unless own_image?
    end

    def should_be_own_files
      error_message = I18n.t('should_be_own_files')
      errors.add(:related_files, error_message) unless own_files?
    end

    def is_image?
      image.archive_content_type =~ /image/
    end

    def own_image?
      image.site_id == site.id
    end

    def own_files?
      related_files.each do |file|
        return false if file.site_id != site.id
      end
      true
    end

  end
end
