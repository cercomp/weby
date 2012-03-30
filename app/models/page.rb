class Page < ActiveRecord::Base
  self.inheritance_column = nil
  acts_as_taggable_on :categories

  scope :published, where(publish: true)

  scope :front, where(front: true)

  scope :titles_like, proc { |title, locale|
    unless locale.blank?
      joins('LEFT JOIN page_i18ns ON pages.id = page_i18ns.page_id 
             LEFT JOIN locales ON page_i18ns.locale_id = locales.id')
             .where(['LOWER(page_i18ns.title) like ? AND locales.name IN (?)', "%#{title.try(:downcase)}%", locale])
    else
      joins('LEFT JOIN page_i18ns ON pages.id = page_i18ns.page_id 
             LEFT JOIN locales ON page_i18ns.locale_id = locales.id')
             .where(['LOWER(page_i18ns.title) like ?', "%#{title.try(:downcase)}%"])
    end
  }

  scope :news, lambda { |front|
    where("front=:front AND date_begin_at <= :time AND( date_end_at is NULL OR date_end_at > :time)",
          { time: Time.now, front: front }).
          published
  }

  validates :type,
    presence: true,
    inclusion: %w[News Event]

  validates :kind,
    inclusion: %w[international national regional],
    allow_nil: true,
    allow_blank: true

  validates :date_begin_at, 
    presence: true

  validates :local,
    presence: { if: proc { self.type == 'Event' } }

  belongs_to :site
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

  def should_be_image
    error_message = I18n.t("should_be_image")
    errors.add(:image, error_message) unless image?
  end
  private :should_be_image

  def image?
    return true if image.blank?
    image.archive_content_type =~ /image/ 
  end
  private :image?

  has_many :menu_items,
    as: :target,
    dependent: :nullify

  has_many :banners,
    dependent: :nullify

  has_many :pages_repositories
  has_many :repositories, through: :pages_repositories
  #accepts_nested_attributes_for :pages_repositories, allow_destroy: true

  #has_many :sites_pages
  #has_many :sites, through: :sites_pages
  #accepts_nested_attributes_for :sites_pages, allow_destroy: true

  # Internationalization
  has_many :i18ns,
    class_name: "Page::I18ns",
    dependent: :delete_all
  accepts_nested_attributes_for :i18ns,
    allow_destroy: true,
    reject_if: :reject_i18ns

  before_validation :initialize_i18n

  def initialize_i18n
    i18ns.each { |i18n| i18n.page = self }
  end
  private :initialize_i18n

  validates_with WebyI18nContentValidator
  validates_associated :i18ns

  def reject_i18ns(attributed)
    attributed['id'].blank? and
      attributed['title'].blank?
  end
  private :reject_i18ns

  # Find i18n based on locale_name
  # Example: locale_name = 'pt-BR'
  def by_locale(locale_name)
    loc = Locale.find_by_name(locale_name)
    page_i18ns.by_locale(loc).first or page_i18ns.first
  end

  # Find current i18n page
  # Try use session[:locale] to find actual i18n
  #def page_i18n(session)
  #  by_locale(session[:locale])
  #end

  # Necessário para o STI(News, Event)
  # Classes filhas devem responder que são Pages
  def self.model_name
    ActiveModel::Name.new(Page)
  end
end
