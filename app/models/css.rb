class Css < ActiveRecord::Base
  has_many :sites_csses
  has_many :sites, :through => :sites_csses
end
