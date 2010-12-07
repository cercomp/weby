class Page < ActiveRecord::Base
  #validates_presence_of :title
  #validates_presence_of :source

  belongs_to :user, :foreign_key => "author_id"

  has_many :sites_pages
  has_many :sites, :through => :sites_pages

  has_attached_file :image, 
     :styles => { :medium => "300X300"},
	 :url => "/uploads/:class/:attachment/:id/:style_:basename.:extension"	
  
  
  accepts_nested_attributes_for :sites_pages, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
end
