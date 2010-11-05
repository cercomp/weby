class Menu < ActiveRecord::Base
  has_many :sites_menus
  has_many :sites, :through => :sites_menus

  accepts_nested_attributes_for :sites_menus, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
end
