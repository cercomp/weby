class Css < ActiveRecord::Base
  has_many :sites_csses
  has_many :sites, :through => :sites_csses

  accepts_nested_attributes_for :sites_csses, :allow_destroy => true
end
