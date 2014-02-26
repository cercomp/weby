class SitesMenu < ActiveRecord::Base
  belongs_to :site
  belongs_to :menu
end
