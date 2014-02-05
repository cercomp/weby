# coding: utf-8
class Style < ActiveRecord::Base
  belongs_to :site
  belongs_to :style

  has_many :styles, dependent: :restrict
  has_many :followers, through: :styles, source: :site
  
  validates :site, presence: true
  validates :name, presence: true, unless: :style_id

  scope :by_name, lambda { |name|
    include(:sites).where('lower(styles.name) like :name OR lower(sites.title) like :name', name: "%#{name.downcase}%") if name
  }

  # returns all styles that are not being followed
  # in follow_styles was used a hack to avoid null return
  scope :not_followed_by, lambda { |site|
    where('id not in (:follow_styles) and site_id <> :site and style_id is null', {
      follow_styles: Site.find(site).styles.where('style_id is not null').map(&:style_id) << 0,
      site: site
    })
  }

  def copy!
    return false unless style_id
    update_attributes(css: css, name: name, style_id: nil)
  end

  def css
    style ? style.css : read_attribute(:css)
  end

  def name
    style ? style.name : read_attribute(:name)
  end

  def owner
    style ? style.site : site
  end
end
