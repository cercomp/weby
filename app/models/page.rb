class Page < ActiveRecord::Base
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

  validates_presence_of :author_id, :date_begin_at

  belongs_to :user, foreign_key: "author_id"
  belongs_to :repository, foreign_key: "repository_id"


  has_many :menus, dependent: :nullify

  has_many :banners, dependent: :nullify

  has_many :pages_repositories
  has_many :repositories, through: :pages_repositories

  has_many :sites_pages
  has_many :sites, through: :sites_pages

  has_many :page_i18ns, dependent: :destroy, validate: false

  accepts_nested_attributes_for :page_i18ns,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :sites_pages, allow_destroy: true
  accepts_nested_attributes_for :pages_repositories, allow_destroy: true

  validate :at_least_one_internationalization

  def at_least_one_internationalization
    error_message = I18n.t("page_need_at_least_one_internationalization") 
    errors.add(:base, error_message) if has_valid_internationalizations?
  end

  def has_valid_internationalizations?
    valid_internationalizations.size <= 0
  end
  private :has_valid_internationalizations?

  def valid_internationalizations
    self.page_i18ns.
      map{ |page_i18n| page_i18n if valid_internationalization?(page_i18n) }.compact
  end
  private :valid_internationalizations

  def valid_internationalization?(page_i18n)
    not page_i18n.marked_for_destruction? and not page_i18n.title.blank?
  end
  private :valid_internationalization?

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
