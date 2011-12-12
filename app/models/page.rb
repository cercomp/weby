class Page < ActiveRecord::Base
  acts_as_taggable_on :categories
  acts_as_list

  default_scope :order => 'pages.position,pages.id desc'

  scope :published, where(:publish => true)

  scope :titles_like, lambda { |title|
    joins('LEFT JOIN page_i18ns ON pages.id = page_i18ns.id 
           LEFT JOIN locales ON page_i18ns.id = locales.id')
           .where(['LOWER(page_i18ns.title) like ?', "%#{title.try(:downcase)}%"])
  }

  scope :news, lambda { |front|
    where("front=:front AND date_begin_at <= :time AND( date_end_at=NULL OR date_end_at > :time)",
          { :time => Time.now, :front => front }).
          published
  }

  validates_presence_of :author_id, :date_begin_at

  belongs_to :user, :foreign_key => "author_id"
	belongs_to :repository, :foreign_key => "repository_id"

  has_many :menus

  has_many :pages_repositories
  has_many :repositories, :through => :pages_repositories

  has_many :sites_pages
  has_many :sites, :through => :sites_pages

  # Teste i18n
  has_many :page_i18ns, :dependent => :destroy

  accepts_nested_attributes_for :page_i18ns, :allow_destroy => true
  accepts_nested_attributes_for :sites_pages, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :pages_repositories, :allow_destroy => true

  # Find i18n based on locale_name
  # Example: locale_name = 'pt-BR'
  def by_locale(locale_name)
    loc = Locale.find_by_name(locale_name)
    page_i18ns.by_locale(loc).first or page_i18ns.first
  end

  # Find current i18n page
  # Try use session[:locale] to find actual i18n
  def page_i18n
    by_locale(session[:locale])
  end

end
