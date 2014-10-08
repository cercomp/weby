class Page < ActiveRecord::Base
  self.inheritance_column = nil

  include Trashable

  weby_content_i18n :title, :summary, :text, required: :title

  acts_as_taggable_on :categories
  acts_as_multisite

  EVENT_TYPES = %w(regional national international)

  belongs_to :owner, class_name: 'Site', foreign_key: 'site_id'
  belongs_to :author, class_name: 'User'
  belongs_to :image, class_name: 'Repository', foreign_key: 'repository_id'

  has_many :views, as: :viewable
  has_many :menu_items, as: :target, dependent: :nullify
  has_many :posts_repositories, as: :post, dependent: :destroy
  has_many :related_files, through: :posts_repositories, source: :repository

  # Validations
  validates :author_id, :site_id, presence: true
  validates :position, presence: { if: proc { self.front? } }
  validates :type, presence: true, inclusion: %w(News Event)
  validates :kind, inclusion: EVENT_TYPES, allow_nil: true, allow_blank: true
  validates :local, :event_begin, presence: { if: proc { self.event? } }

  validate :validate_date
  validate :should_be_image
  validate :should_be_own_image
  validate :should_be_own_files

  scope :published, -> { where(publish: true) }

  scope :news, -> { where(type: 'News') }
  scope :events, -> { where(type: 'Event') }

  scope :upcoming_events, -> { where(' (event_begin >= :time OR event_end >= :time)', time: Time.now).events }
  scope :previous_events, -> { where(' (event_end < :time)', time: Time.now).events }

  scope :front, -> { where(front: true) }
  scope :no_front, -> { where(front: false) }
  scope :by_author, ->(id) { where(author_id: id) }

  scope :available, -> { where('date_begin_at is NULL OR date_begin_at <= :time', time: Time.now).published }
  scope :available_fronts, -> { front.available.where('date_end_at is NULL OR date_end_at > :time', time: Time.now) }

  # tipos de busca
  # 0 = "termo1 termo2"
  # 1 = termo1 AND termo2
  # 2 = termo1 OR termo2
  scope :search, ->(param, search_type) {
    if param.present?
      fields = ['page_i18ns.title', 'page_i18ns.summary', 'page_i18ns.text',
                'users.first_name', 'pages.type', 'tags.name']
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
      includes(:author, :categories, :i18ns, :locales)
      .where(query, values)
      .references(:author, :categories, :i18ns)
    end
  }

  before_trash do
    if publish
      errors[:base] << I18n.t('cannot_destroy_a_published_page')
      false
    else
      self.front = false
      true
    end
  end

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['page'] if attrs.key? 'page'

    attrs.except!('id', 'created_at', 'updated_at', 'site_id')

    attrs['author_id'] = options[:author] unless User.unscoped.find_by_id(attrs['author_id'])
    attrs['repository_id'] = Import::Application::CONVAR["repository"]["#{attrs['repository_id']}"]

    attrs['i18ns'] = attrs['i18ns'].map do |i18n|
      i18n['summary'] = i18n['summary'].gsub!(/\/up\/[0-9]+/) {|x| "/up/#{options[:site_id]}"} if i18n['summary']
      i18n['text'] =  i18n['text'].gsub!(/\/up\/[0-9]+/) {|x| "/up/#{options[:site_id]}"} if i18n['text']
      self::I18ns.new(i18n.except('id', 'created_at', 'updated_at', 'page_id', 'type'))
    end

    categories = attrs.delete('categories')

    newpage = self.create!(attrs)

    categories.each do |category|
      newpage.category_list << category['name']
      newpage.save
    end
  end

  def to_param
    "#{id} #{title}".parameterize
  end

  def event?
    type == 'Event'
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
    image.site_id == owner.id
  end

  def own_files?
    related_files.each do |file|
      return false if file.site_id != owner.id
    end
    true
  end
end
