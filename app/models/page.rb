class Page < ActiveRecord::Base
  belongs_to :user, :foreign_key => "author_id"
	belongs_to :repository, :foreign_key => "repository_id"

	has_and_belongs_to_many :repositories

  has_many :sites_pages
  has_many :sites, :through => :sites_pages

  accepts_nested_attributes_for :sites_pages, :allow_destroy => true#, :reject_if => proc { |attributes| attributes['title'].blank? }
end
