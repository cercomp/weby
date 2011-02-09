class Site < ActiveRecord::Base
  def to_param
    "#{name}"
  end
  validates_presence_of :name, :url
  
  # Removido para utilizar a relação ternária entre roles e sites
    #has_many :sites_users #, :foreign_key => "role_id"
    #has_many :users, :through => :sites_users

  has_many :user_site_enroled, :dependent => :destroy
  has_many :users, :through => :user_site_enroled
  has_many :roles, :through => :user_site_enroled

  has_many :sites_menus
  has_many :menus, :through => :sites_menus

  has_many :sites_pages
  has_many :pages, :through => :sites_pages
  
  has_many :sites_banners
  has_many :banners, :through => :sites_banners

  has_many :groups
  has_many :feedbacks

  #accepts_nested_attributes_for :sites_users, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :sites_menus, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :sites_pages, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
 
 	belongs_to :repository, :foreign_key => "top_banner_id"
  has_many :repositories

	 has_attached_file :top_banner, :url => "/uploads/:site_id/:style_:basename.:extension"

end
