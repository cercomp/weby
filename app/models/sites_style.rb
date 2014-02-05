class SitesStyle < ActiveRecord::Base
  belongs_to :site
  belongs_to :style

  validates :site, presence: true
  validates :style, presence: true

  validates :style_id, uniqueness: { scope: :site_id }
end
