class SitesStyle < ActiveRecord::Base
  belongs_to :site
  belongs_to :style

  validates_uniqueness_of :style_id, :scope => :site_id
end
