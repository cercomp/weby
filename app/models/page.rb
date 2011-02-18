class Page < ActiveRecord::Base
  default_scope :order => 'updated_at DESC'
  validates_presence_of :title, :source, :author_id

  belongs_to :user, :foreign_key => "author_id"
	belongs_to :repository, :foreign_key => "repository_id"
  
  has_many :menus

  has_many :pages_repositories
  has_many :repositories, :through => :pages_repositories

  has_many :sites_pages
  has_many :sites, :through => :sites_pages

  accepts_nested_attributes_for :sites_pages, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :pages_repositories
end
