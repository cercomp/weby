class Site < ActiveRecord::Base
  before_save :clear_per_page

  default_scope :order => 'sites.id DESC'

  def to_param
    "#{name}"
  end

  scope :name_or_description_like, lambda { |text|
    where('lower(name) LIKE :text OR lower(description) LIKE :text',
          { :text => "%#{text}%" })
  }

  # TODO tentar agrupar os 3 metodos a seguir em apenas 1
  def page_categories
    # FIXME: Verificar se Rails possui um método para isso.
    self.pages.unscoped.find(:all, :select => 'DISTINCT category').map{ |m| m.category }.uniq
  end

  def banner_categories
    #self.banners.map{ |m| m.category }.uniq
    self.banners.unscoped.find(:all, :select => 'DISTINCT category').map{ |m| m.category }.uniq
  end

  def menu_categories
    #self.sites_menus.map{ |m| m.category }.uniq
    self.menus.unscoped.find(:all, :select => 'DISTINCT category').map{ |m| m.category }.uniq
  end

  validates_presence_of :name, :url, :per_page

  validates_uniqueness_of :name

  validates_format_of :per_page, :with => /([0-9]+[,\s]*)+[0-9]*/

  has_many :roles

  has_one :repository

  has_many :sites_menus
  has_many :menus, :through => :sites_menus

  has_many :sites_pages
  has_many :pages, :through => :sites_pages

  has_many :groups
  has_many :feedbacks
  has_many :banners

  has_many :sites_csses
  has_many :csses, :through => :sites_csses

  has_many :components

  accepts_nested_attributes_for :sites_menus, :allow_destroy => true
  accepts_nested_attributes_for :sites_pages, :allow_destroy => true

  belongs_to :repository, :foreign_key => "top_banner_id"
  has_many :repositories

  has_attached_file :top_banner, :url => "/uploads/:site_id/:style_:basename.:extension"
  private
  def clear_per_page
    self.per_page.gsub!(/[^\d,]/,'')
    self.per_page.gsub!(',,',',')
  end
end
