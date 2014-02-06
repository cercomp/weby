# coding: utf-8
class Style < ActiveRecord::Base
  belongs_to :site
  belongs_to :style

  has_many :styles, dependent: :restrict
  has_many :followers, through: :styles, source: :site
  
  validates :site, presence: true
  validates :name, presence: true, unless: :style_id
  validates :style_id, uniqueness: { scope: :site_id }, if: :style_id

  scope :search, lambda { |param|
    fields = ['styles.name', 'sites.title', 'sites.name']
    includes(:site).where(fields.map{|field| "lower(#{field}) like :param"}.join(" OR "), param: "%#{param.downcase}%") if param
  }

  # returns all styles that are not being followed
  # in follow_styles was used a hack to avoid null return
  scope :not_followed_by, lambda { |site|
    where('styles.id not in (:follow_styles) and styles.site_id <> :site_id and styles.style_id is null', {
      follow_styles: Site.find(site).styles.where('style_id is not null').map(&:style_id) << 0,
      site_id: site
    })
  }

  scope :published, where(publish: true)

  after_create do |style|
    update_attribute(:position, style.site.styles.maximum(:position)+1)
  end

  def copy! to_site
    if site == to_site
      return false unless self.style_id
      update_attributes(css: css, name: name, style_id: nil)
    else
      return false if self.style_id
      Style.create(name: self.name, css: self.css, site: to_site).persisted?
    end
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
