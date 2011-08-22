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

  def my_csses
    sites_csses.where(:owner => true)
  end

  def other_csses
    SitesCss.where(['(
                        site_id = :site_id AND owner = false
                     ) OR (
                        site_id <> :site_id AND css_id NOT IN (
                          SELECT css_id FROM sites_csses WHERE site_id = :site_id
                        )
                     )',
             {:site_id => self.id}]).order(:owner, :site_id, :css_id)
  end

  # TODO tentar agrupar os 3 metodos a seguir em apenas 1
  def page_categories
    self.pages.except(:order, :select).find(:all, :select => 'DISTINCT category').map{ |m| m.category }
  end

  def banner_categories
    self.banners.except(:order, :select).find(:all, :select => 'DISTINCT category').map{ |m| m.category }
  end

  def menu_categories
    self.sites_menus.except(:order, :select).find(:all, :select => 'DISTINCT category').map{ |m| m.category }
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

  # FIXME testando relação de componentes
  has_many :site_components

  accepts_nested_attributes_for :sites_menus, :allow_destroy => true
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
