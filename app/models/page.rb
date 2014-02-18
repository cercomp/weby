class Page < ActiveRecord::Base
  include Trashable
  weby_content_i18n :title, :summary, :text, required: :title

  EVENT_TYPES = %w[regional national international]

  self.inheritance_column = nil

  acts_as_taggable_on :categories
  acts_as_multisite

  #Relations
  belongs_to :owner, class_name: "Site", foreign_key: "site_id"
  belongs_to :author, class_name: "User"
  belongs_to :image, class_name: 'Repository', foreign_key: 'repository_id'

  has_many :views, as: :viewable
  has_many :menu_items, as: :target, dependent: :nullify
  has_many :banners, dependent: :nullify
  has_many :pages_repositories, dependent: :destroy
  has_many :related_files, through: :pages_repositories, source: :repository

  #Validations
  validates :author_id, :site_id, presence: true
  validates :position, presence: {if: proc { self.front? }}
  validates :type, presence: true, inclusion: %w[News Event]
  validates :kind, inclusion: EVENT_TYPES, allow_nil: true, allow_blank: true
  validates :local, :event_begin, presence: {if: proc { self.event? }}

  validate :validate_date
  def validate_date
    if self.date_begin_at.blank?
      self.date_begin_at = Time.now.to_s
    end
  end

  def self.import attrs, options={}
    return attrs.each{|attr| self.import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['page'] if attrs.has_key? 'page'

    attrs.except!('id', 'created_at', 'updated_at', 'site_id')

    attrs['author_id'] = options[:author] unless User.unscoped.find_by_id(attrs['author_id'])
    attrs['repository_id'] = ''

    attrs['i18ns'] = attrs['i18ns'].map{|i18n| self::I18ns.new(i18n.except('id', 'created_at', 'updated_at', 'page_id', 'type')) }

    page = self.create!(attrs)

  end

  private :validate_date

  validate :should_be_image
  def should_be_image
    return unless image
    error_message = I18n.t("should_be_image")
    errors.add(:image, error_message) unless is_image?
  end
  private :should_be_image

  validate :should_be_own_image
  def should_be_own_image
    return unless image
    error_message = I18n.t("should_be_own_image")
    errors.add(:image, error_message) unless own_image?
  end
  private :should_be_own_image

  validate :should_be_own_files
  def should_be_own_files
    error_message = I18n.t("should_be_own_files")
    errors.add(:related_files, error_message) unless own_files?
  end
  private :should_be_own_files

  #Callbacks
  before_trash do
    if publish
      errors[:base] << I18n.t("cannot_destroy_a_published_page")
      false
    else
      self.front = false
      true
    end
  end

  #Scopes
  scope :published, where(publish: true)

  scope :news, where(type: 'News')
  scope :events, where(type: 'Event')
  
  scope :upcoming_events, proc{ where(" (event_begin >= :time OR event_end >= :time)", time: Time.now).events }

  scope :front, where(front: true)
  scope :no_front, where(front: false)
  scope :by_author, lambda { |id| where(author_id: id) }

  scope :available, proc { where("date_begin_at <= :time AND ( date_end_at is NULL OR date_end_at > :time)",
                                 { time: Time.now }).published }
  # tipos de busca
  # 0 = "termo1 termo2"
  # 1 = termo1 AND termo2
  # 2 = termo1 OR termo2
  scope :search, lambda { |param, search_type|
    if param.present?
      fields = ["page_i18ns.title", "page_i18ns.summary", "page_i18ns.text",
      "users.first_name", "pages.type", "tags.name"]
      query, values = "", {}
      case search_type
      when 0
        query = fields.map { |field| "LOWER(#{field}) LIKE :param"}.join(" OR ")
        values[:param] = "%#{param.try(:downcase)}%"
      when 1, 2
        keywords = param.split(' ')
        query = fields.map do |field|
          "(#{
              keywords.each_with_index.map do |keyword, idx|
                values["key#{idx}".to_sym] = "%#{keyword.try(:downcase)}%"
                "LOWER(#{field}) LIKE :key#{idx}"
              end.join(search_type == 1 ? " AND " : " OR ")
          })"
        end.join(" OR ")
      end
      includes(:author, :categories, :i18ns, :locales).
      where(query, values)
    end
  }

  def event?
    type == 'Event'
  end

  def image=(file)
    return self.repository_id = file.id if file.is_a?(Repository)
    self.repository_id = file
  end

  def self.uniq_category_counts
    self.category_counts.inject(Hash.new) do |hash,j|
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
    return true
  end
end
