# coding: utf-8

class Style < ActiveRecord::Base
  has_many :sites_styles, dependent: :destroy
  has_many :followers, through: :sites_styles, source: :site

  belongs_to :owner, foreign_key: :owner_id, class_name: "Site"
  validates :owner_id,
    presence: true,
    numericality: true

  accepts_nested_attributes_for :sites_styles, :allow_destroy => true
  validates_presence_of :name

  scope :by_name, lambda { |name|
    where(['name like :name', { name: "%#{name}%" } ])
  }

  scope :by, lambda { |site_id|
    where(['owner_id = :site_id', { site_id: site_id } ])
  }

  # returns all styles that are not being followed
  # in follow_styles was used a hack to avoid null return
  scope :not_followed_by, lambda { |site_id|
    where(['id not in (:follow_styles) and owner_id <> :site', {
      follow_styles: Site.find(site_id).follow_styles.map { |follow_style| follow_style.id } << 0,
      site: site_id 
    }])
  }
end
