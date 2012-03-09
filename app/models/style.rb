class Style < ActiveRecord::Base
  has_many :sites_styles, :dependent => :destroy
  has_many :sites, :through => :sites_styles

  accepts_nested_attributes_for :sites_styles, :allow_destroy => true
  validates_presence_of :name

  def owner
    sites_styles.where(:owner => true).first.site
  end
end
