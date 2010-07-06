class Menu < ActiveRecord::Base
  belongs_to :menu, :foreign_key => "father_id"

  has_many :sites_menus
  has_many :sites, :through => :sites_menus
end
