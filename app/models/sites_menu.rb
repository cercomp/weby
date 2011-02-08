class SitesMenu < ActiveRecord::Base
  default_scope :order => 'position'

  belongs_to :site
  belongs_to :menu
end
