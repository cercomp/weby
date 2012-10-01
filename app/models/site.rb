class Site < ActiveRecord::Base
  before_save :clear_per_page

  def to_param
    "#{name}"
  end

  scope :name_or_description_like, lambda { |text|
    where('lower(name) LIKE lower(:text) OR lower(description) LIKE lower(:text)',
          { :text => "%#{text}%" })
  }

  validates :url,
    presence: true,
    format: { with: /^http[s]{,1}:\/\/[\w\.\-\%\#\=\?\&]+\.([\w\.\-\%\#\=\?\&]+\/{,1})*/i }

  validates :name,
    presence: true,
     uniqueness: {:scope => :parent_id},
      format: { with: /^[a-z0-9_\-]+$/ }


  validates :per_page,
    presence: true,
    format: { with: /([0-9]+[,\s]*)+[0-9]*/ }

  validates :title,
    :length => { :maximum => 50 }

  has_many :subsites,
    foreign_key: :parent_id,
    class_name: "Site"

  belongs_to :main_site,
    foreign_key: :parent_id,
    class_name: "Site"

  has_many :roles

  has_one :repository

  has_many :menus, dependent: :delete_all, order: :id
  has_many :menu_items, :through => :menus

  has_many :pages,
    include: :i18ns,
    dependent: :delete_all

  has_many :pages_i18ns, through: :pages, source: :i18ns

  has_many :groups
  has_many :feedbacks
  has_many :banners, order: :position

  has_many :sites_styles,
    dependent: :destroy
  has_many :follow_styles,
    through: :sites_styles,
    source: :style
  
  has_many :own_styles,
    foreign_key: :owner_id,
    dependent: :destroy,
    class_name: "Style"

  has_many :components, order: 'place_holder, position asc'

  belongs_to :repository, :foreign_key => "top_banner_id"
  has_many :repositories

  has_many :extensions, :class_name => 'ExtensionSite'

  has_and_belongs_to_many :locales

  validate :at_least_one_locale

  def at_least_one_locale
    if self.locales.length < 1
      errors.add(:site, I18n.t("site_need_at_least_one_locale"))
    end
  end

  def has_extension(extension)
    extensions.include? ExtensionSite.find_by_name(mod.to_s)
  end

  has_attached_file :top_banner, :url => "/uploads/:site_id/:style_:basename.:extension"
  private
  def clear_per_page
    self.per_page.gsub!(/[^\d,]/,'')
    self.per_page.gsub!(',,',',')
  end
end
