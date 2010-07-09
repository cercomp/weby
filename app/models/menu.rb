class Menu < ActiveRecord::Base
  belongs_to :menu, :foreign_key => "father_id"

  has_many :sites_menus
  has_many :sites, :through => :sites_menus

  accepts_nested_attributes_for :sites_menus, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
end
