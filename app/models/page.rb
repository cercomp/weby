class Page < ActiveRecord::Base
  self.inheritance_column = nil

  include Weby::ContentI18n::Base

  EVENT_TYPES = %w[regional national international]

  acts_as_taggable_on :categories

  scope :published, where(publish: true)

  scope :news, where(type: 'News')
  scope :events, where(type: 'Event')

  scope :front, where(front: true)

  scope :valid, where("date_begin_at <= :time AND ( date_end_at is NULL OR date_end_at > :time)",
                      { time: Time.now }).published

  scope :titles_like, proc { |title, locale|
    if locale.blank?
      joins('LEFT JOIN page_i18ns ON pages.id = page_i18ns.page_id 
             LEFT JOIN locales ON page_i18ns.locale_id = locales.id')
             .where(['LOWER(page_i18ns.title) like :title',
                     { title: "%#{title.try(:downcase)}%" }
             ])
    else
      joins('LEFT JOIN page_i18ns ON pages.id = page_i18ns.page_id 
             LEFT JOIN locales ON page_i18ns.locale_id = locales.id')
             .where(['LOWER(page_i18ns.title) like :title AND locales.name IN (:locale)',
                     { title: "%#{title.try(:downcase)}%", locale: locale}
             ])
    end
  }

  def event?
    type == 'Event'
  end

  validates :type,
    presence: true,
    inclusion: %w[News Event]

  validates :kind,
    inclusion: EVENT_TYPES,
    allow_nil: true,
    allow_blank: true

  validates :date_begin_at, 
    presence: true

  validates :local,
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

  has_many :pages_repositories
  has_many :related_files, through: :pages_repositories, source: :repository
  validate :should_be_own_files

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

  has_many :i18ns,
    class_name: "Page::I18ns",
    include: :locale,
    dependent: :delete_all

  has_many :locales, through: :i18ns
  accepts_nested_attributes_for :i18ns,
    allow_destroy: true,
    reject_if: :reject_i18ns

  before_validation :initialize_i18n
  #validates_associated :i18ns

  def initialize_i18n
    i18ns.each { |i18n| i18n.page = self }
  end
  private :initialize_i18n

  def reject_i18ns(attributed)
    attributed['id'].blank? and
      attributed['title'].blank?
  end
  private :reject_i18ns

end
