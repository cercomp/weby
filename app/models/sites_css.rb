class SitesCss < ActiveRecord::Base
  belongs_to :site
  belongs_to :css
end
