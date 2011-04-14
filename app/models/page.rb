class Page < ActiveRecord::Base
  default_scope :order => 'position'

  scope :published, where(:publish => true)

  scope :titles_like, lambda { |title|
      where(["LOWER(title) like ?", "%#{title.downcase if title}%"])
  }

  scope :news, lambda { |front|
    where(["front='true' AND date_begin_at <= ? AND date_end_at > ?",
           Time.now,
           Time.now]).published
  }

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
  acts_as_list 

end
