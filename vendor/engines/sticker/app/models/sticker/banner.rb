module Sticker
  class Banner < ActiveRecord::Base
    belongs_to :target, polymorphic: true
    belongs_to :repository
    belongs_to :user
    belongs_to :site

    has_many :banner_sites, foreign_key: :sticker_banner_id, class_name: "::Sticker::BannerSite", dependent: :destroy
    has_many :sites, through: :banner_sites
    has_one :own_banner_site, ->(this){ where(site_id: this.site_id) }, class_name: "::Sticker::BannerSite", foreign_key: :sticker_banner_id

    validates :title, :user_id, presence: true

    scope :published, -> { where(publish: true) }

    scope :titles_or_texts_like, ->(str) {
      where("LOWER(title) like :str OR
           LOWER(text) like :str",  str: "%#{str.try(:downcase)}%")
    }

    accepts_nested_attributes_for :banner_sites, allow_destroy: true

    def owned_by? site
      site_id == site.id
    end

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['banner'] if attrs.key? 'banner'

      attrs.except!('id', 'type', '@type', 'created_at', 'updated_at', 'site_id')

      attrs['repository_id'] = Import::Application::CONVAR["repository"]["#{attrs['repository_id']}"]
      attrs['user_id'] = options[:user] unless User.unscoped.find_by(id: attrs['user_id'])

      self.create!(attrs)
    end
  end
end
