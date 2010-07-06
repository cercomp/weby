class Page < ActiveRecord::Base
  belongs_to :user, :foreign_key => "autor_id"

  has_many :sites_pages
  has_many :sites, :through => :sites_pages
end
