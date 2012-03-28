class SitesStyle < ActiveRecord::Base
  belongs_to :site
  belongs_to :style

  validates :site_id,
    presence: true,
    numericality: true

  validates :style_id,
    presence: true,
    numericality: true 

  validates_uniqueness_of :style_id, :scope => :site_id
end
