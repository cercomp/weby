class Site < ActiveRecord::Base
  before_save :clear_per_page

  def to_param
    "#{name}"
  end

  scope :name_or_description_like, lambda { |text|
    where('lower(name) LIKE :text OR lower(description) LIKE :text',
          { :text => "%#{text}%" })
  }

  validates :url,
    presence: true,
    format: { with: /^http[s]{,1}:\/\/[\w\.\-\%\#\=\?\&]+\.([\w\.\-\%\#\=\?\&]+\/{,1})*/i }

  validates :name,
    presence: true,
    uniqueness: true

  validates :per_page,
    presence: true,
    format: { with: /([0-9]+[,\s]*)+[0-9]*/ }

  has_many :roles

  has_one :repository

  has_many :menus, dependent: :delete_all, order: :id
  has_many :menu_items, :through => :menus, dependent: :delete_all

  has_many :sites_pages
  has_many :pages, :through => :sites_pages

  has_many :groups
  has_many :feedbacks
  has_many :banners

  has_many :sites_styles,
    dependent: :destroy
  has_many :follow_styles,
    through: :sites_styles,
    source: :style
  
  has_many :own_styles,
    foreign_key: :owner_id,
    dependent: :destroy,
    class_name: "Style"

  # FIXME testando relação de componentes
  has_many :site_components

  accepts_nested_attributes_for :sites_pages, :allow_destroy => true

  belongs_to :repository, :foreign_key => "top_banner_id"
  has_many :repositories

  has_and_belongs_to_many :locales

  has_attached_file :top_banner, :url => "/uploads/:site_id/:style_:basename.:extension"
  private
  def clear_per_page
    self.per_page.gsub!(/[^\d,]/,'')
    self.per_page.gsub!(',,',',')
  end
end
