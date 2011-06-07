class SitesCss < ActiveRecord::Base
  belongs_to :site
  belongs_to :css

  validates_uniqueness_of :css_id, :scope => :site_id
end
