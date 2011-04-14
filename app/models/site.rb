class Site < ActiveRecord::Base
  before_save :clear_per_page

  default_scope :order => 'id DESC'

  def to_param
    "#{name}"
  end

  def self.search(search, page, order = 'id desc', per_page = 20)
    paginate :per_page => per_page, :page => page, :conditions => ['lower(name) LIKE ? OR lower(description) LIKE ?', "%#{search}%", "%#{search}%"],
    :order => order
  end

  validates_presence_of :name, :url, :per_page

  validates_uniqueness_of :name

  validates_format_of :per_page, :with => /([0-9]+[,\s]*)+[0-9]*/

  has_many :roles

  has_many :sites_menus
  has_many :menus, :through => :sites_menus

  has_many :sites_pages
  has_many :pages, :through => :sites_pages

  has_many :groups
  has_many :feedbacks
  has_many :banners

  has_many :sites_csses
  has_many :csses, :through => :sites_csses

  #accepts_nested_attributes_for :sites_users, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :sites_menus, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :sites_pages, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }

  belongs_to :repository, :foreign_key => "top_banner_id"
  has_many :repositories

  has_attached_file :top_banner, :url => "/uploads/:site_id/:style_:basename.:extension"
  private
  def clear_per_page
    self.per_page.gsub!(/[^\d,]/,'')
    self.per_page.gsub!(',,',',')
  end
end
