class Menu < ActiveRecord::Base
  validates_presence_of :title
 
  has_many :sites_menus
  has_many :sites, :through => :sites_menus

  belongs_to :page, :foreign_key => "page_id"

  accepts_nested_attributes_for :sites_menus, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }

end
