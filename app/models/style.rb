# coding: utf-8

class Style < ActiveRecord::Base
  belongs_to :owner, class_name: "Site"

  has_many :sites_styles, dependent: :destroy
  has_many :followers, through: :sites_styles, source: :site

  accepts_nested_attributes_for :sites_styles, :allow_destroy => true

  validates :name, presence: true
  validates :owner, presence: true

  scope :by_name, lambda { |name|
    where(['lower(name) like :name', { name: "%#{name.downcase}%" } ])
  }

  # TODO: mudar nome para by_owner
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

  def mine(owner_id)
    return self if self.owner_id == owner_id

    self.sites_styles.find_by_site_id(owner_id)
  end

  def self.import attrs, options={}
    return attrs.each{|attr| self.import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['own_styles'] if attrs.has_key? 'own_styles'

    attrs.except!('id', 'created_at', 'updated_at')

    style = self.create!(attrs)

  end

end
