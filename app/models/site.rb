class Site < ActiveRecord::Base
  has_many :sites_users #, :foreign_key => "role_id"
  has_many :users, :through => :sites_users

  has_many :sites_menus
  has_many :menus, :through => :sites_menus

  has_many :sites_pages
  has_many :pages, :through => :sites_pages

  validates_presence_of :name
end
