class SitesBanner < ActiveRecord::Base
  belongs_to :site
  belongs_to :banner
end
