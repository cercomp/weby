class Site < ActiveRecord::Base
  has_many :sites_users #, :foreign_key => "role_id"
  has_many :users, :through => :sites_users

  has_many :sites_menus
  has_many :menus, :through => :sites_menus

  has_many :sites_pages
  has_many :pages, :through => :sites_pages

  has_many :feedbacks

  accepts_nested_attributes_for :sites_users, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :sites_menus, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :sites_pages, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
  validates_presence_of :name
end
