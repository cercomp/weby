class Page < ActiveRecord::Base
  include Trashable

  self.inheritance_column = nil

  acts_as_multisite

  weby_content_i18n :title, :summary, :text, required: :title

  EVENT_TYPES = %w[regional national international]

  acts_as_taggable_on :categories

  scope :published, where(publish: true)

  scope :news, where(type: 'News')
  scope :events, where(type: 'Event')
  
  scope :upcoming_events, proc{ where(" (event_begin >= :time OR event_end >= :time)", time: Time.now).events }

  scope :front, where(front: true)
  scope :no_front, where(front: false)

  scope :available, proc { where("date_begin_at <= :time AND ( date_end_at is NULL OR date_end_at > :time)",
                                 { time: Time.now }).published }
  # tipos de busca
  # 0 = "termo1 termo2"
  # 1 = termo1 AND termo2
  # 2 = termo1 OR termo2
  scope :search, lambda { |param, search_type|
      fields = ["page_i18ns.title", "page_i18ns.summary", "page_i18ns.text",
        "users.first_name", "pages.type", "tags.name"]
      query, values = "", {}
      if param.present?
        keys = param.split(' ')
        fields.each_with_index do |field, findex|
          query << " #{findex == 0 ? "" : "OR"} ("
          if search_type > 0
            keys.each_with_index { |key, kindex|
              query << " #{kindex == 0 ? "" : search_type == 1 ? "AND" : "OR"} LOWER(#{field}) LIKE :key#{kindex} ";
              values["key#{kindex}".to_sym] = "%#{key.try(:downcase)}%";
            }
          else
            query << " LOWER(#{field}) LIKE :param "
            values[:param] = "%#{param.try(:downcase)}%"
          end
          query << ") "
        end
      end
      includes(:author, :categories, :i18ns, :locales).
      where([query,values])
  }

  scope :by_author, lambda { |id|
    where(author_id: id)
  }

  def event?
    type == 'Event'
  end

  validates :position,
    presence: true,
    if: proc { |page| page.front? }

  validates :type,
    presence: true,
    inclusion: %w[News Event]

  validates :kind,
    inclusion: EVENT_TYPES,
    allow_nil: true,
    allow_blank: true

  validate :validate_date 
  def validate_date 
    if self.date_begin_at.blank?
      self.date_begin_at = Time.now.to_s
    end
  end

  def self.import attrs, options={}
    return attrs.each{|attr| self.import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['page'] if attrs.has_key? 'page'

    attrs.except!('id', 'created_at', 'updated_at', 'site_id')

    attrs['repository_id'] = ''

    attrs['i18ns'] = attrs['i18ns'].map{|i18n| self::I18ns.new(i18n.except('id', 'created_at', 'updated_at', 'page_id')) }

    page = self.create!(attrs)

  end

  private :validate_date

  validates :local, :event_begin,
    presence: { if: proc { self.type == 'Event' } }

  belongs_to :owner,
    class_name: "Site",
    foreign_key: "site_id"
  validates :site_id,
    presence: true

  belongs_to :author,
    class_name: "User"
  validates :author_id,
    presence: true

  belongs_to :image,
    class_name: 'Repository',
    foreign_key: 'repository_id'
  validate :should_be_image
  validate :should_be_own_image

  has_many :views, as: :viewable

  def should_be_image
    return unless have_image?
    error_message = I18n.t("should_be_image")
    errors.add(:image, error_message) unless image?
  end
  private :should_be_image

  def image?
    image.archive_content_type =~ /image/
  end
  private :image?

  def should_be_own_image
    return unless have_image?
    error_message = I18n.t("should_be_own_image")
    errors.add(:image, error_message) unless own_image?
  end
  private :should_be_own_image

  def own_image?
    image.site_id == owner.id
  end
  private :own_image?

  def have_image?
    not image.blank?
  end
  private :have_image?

  def image=(file)
    return self.repository_id = file.id if file.is_a?(Repository)

    self.repository_id = file
  end

  has_many :menu_items,
    as: :target,
    dependent: :nullify

  has_many :banners,
    dependent: :nullify

  has_many :pages_repositories, :dependent => :destroy
  has_many :related_files, through: :pages_repositories, source: :repository
  validate :should_be_own_files

  def before_trash
    if publish
      self.errors[:base] << I18n.t("cannot_destroy_a_published_page")
      false
    else
      self.update_attribute(:front, false)
      true
    end
  end
  private :before_trash
  
  def should_be_own_files
    error_message = I18n.t("should_be_own_files")
    errors.add(:related_files, error_message) unless own_files?
  end
  private :should_be_own_image

  def own_files?
    related_files.each do |file|
      return false if file.site_id != owner.id
    end
    return true
  end
  private :own_files?

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

end
