class Site < ApplicationRecord
  SHAREABLES = [:page, :news, :event]

  belongs_to :main_site, foreign_key: :parent_id, class_name: 'Site'
  belongs_to :repository, foreign_key: 'top_banner_id'

  has_many :subsites, foreign_key: :parent_id, class_name: 'Site', dependent: :nullify
  has_many :roles, dependent: :destroy
  has_many :users, through: :roles
  has_many :views, dependent: :delete_all
  has_many :activity_records, dependent: :destroy
  has_many :menus, -> { order(position: :asc) }, dependent: :destroy
  has_many :menu_items, through: :menus
  has_many :pages, -> { includes(:i18ns) }, dependent: :destroy
  has_many :pages_i18ns, through: :pages, source: :i18ns
  has_many :repositories, dependent: :destroy
  has_many :extensions, dependent: :destroy
  has_one :theme
  # Extensions relations
  has_many :news_sites, class_name: "::Journal::NewsSite", dependent: :destroy
  has_many :news, through: :news_sites, source: :news
  has_many :own_news, class_name: "::Journal::News", dependent: :destroy
  has_many :groups, class_name: 'Feedback::Group', dependent: :destroy
  has_many :messages, class_name: 'Feedback::Message', dependent: :destroy
  has_many :banner_sites, class_name: "::Sticker::BannerSite", dependent: :destroy
  has_many :banners, through: :banner_sites, source: :banner
  has_many :own_banners, class_name: 'Sticker::Banner', dependent: :destroy
  has_many :events, class_name: 'Calendar::Event', dependent: :destroy
  has_many :skins, dependent: :destroy
  #has_many :components, through: :skins
  has_many :styles, through: :skins

  has_and_belongs_to_many :locales
  has_and_belongs_to_many :groupings

  before_destroy do
    repositories.update_all(archive_file_name: nil)
  end

  validates :name, :title, :url, :per_page, presence: true
  validates :url, format: { with: /\Ahttp[s]{,1}:\/\/[\w\.\-\%\#\=\?\&]+\.([\w\.\-\%\#\=\?\&]+\/{,1})*\z/i }
  validates :name, uniqueness: { scope: :parent_id }, format: { with: /\A^[a-z0-9_\-]+\z/ }
  validates :per_page, format: { with: /\A([0-9]+[,\s]*)+[0-9]*\z/ }
  validates :title, length: { maximum: 50 }

  validate :at_least_one_locale

  scope :active, -> { where(status: 'active') }

  scope :name_or_description_like, ->(text) {
    if text.present?
      where('lower(sites.name) LIKE lower(:text) OR
             lower(sites.description) LIKE lower(:text) OR
             lower(sites.title) LIKE lower(:text)', text: "%#{text}%")
    else
      where(nil)
    end
  }

  scope :ordered_by_front_pages, ->(text) {
    page_query = Journal::News.select("coalesce(max(journal_news.updated_at),'1900-01-01')")
      .published.where('journal_news.site_id = sites.id').to_sql

    name_or_description_like(text).order("(#{page_query}) DESC")
  }

  scope :visible, -> {
    includes(:groupings)
      .where("groupings.hidden = false OR groupings.hidden is NULL")
      .references(:groupings)
  }

  before_save :clear_per_page

  def theme
    Weby::Themes.theme(active_skin.try(:theme))
  end

  def active_skin
    skins.find_by(active: true) || Skin.new
  end

  def favicon
    repositories.find_by(archive_file_name: 'favicon.png')
  end

  def to_label
    "#{name}#{".#{main_site.name}" if main_site} (#{title})"
  end

  def has_extension(extension)
    extensions.select { |ext| ext.name == extension.to_s }.any?
  end

  def active_extensions
    extensions.to_a.keep_if { |extension| Weby.extensions[extension.name.to_sym] }
  end

  def active?
    status == 'active'
  end

  SHAREABLES.each do |shareable|
    define_method("#{shareable}_social_share_pos") { settings["#{shareable}.social_share_pos"] }
    define_method("#{shareable}_social_share_pos=") { |value| settings["#{shareable}.social_share_pos"] = value }

    define_method("#{shareable}_social_share_networks") { settings["#{shareable}.social_share_networks"] }
    define_method("#{shareable}_social_share_networks=") { |value| settings["#{shareable}.social_share_networks"] = value }

    define_method("#{shareable}_facebook_comments") { settings["#{shareable}.facebook_comments"] }
    define_method("#{shareable}_facebook_comments=") { |value| settings["#{shareable}.facebook_comments"] = value }
  end

  def generate_components_yml theme
    skins.find_by(theme: theme)&.components_yml
  end

  private

  def at_least_one_locale
    if locales.length < 1
      errors.add(:locales, I18n.t('site_need_at_least_one_locale'))
    end
  end

  def clear_per_page
    per_page.gsub!(/[^\d,]/, '')
    per_page.gsub!(',,', ',')
  end
end
