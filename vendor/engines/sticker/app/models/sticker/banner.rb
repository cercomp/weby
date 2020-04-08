module Sticker
  class Banner < Sticker::ApplicationRecord
    belongs_to :target, polymorphic: true, optional: true
    belongs_to :repository, optional: true
    belongs_to :user
    belongs_to :site

    has_many :banner_sites, foreign_key: :sticker_banner_id, class_name: "::Sticker::BannerSite", dependent: :destroy
    has_many :sites, through: :banner_sites
    has_one :own_banner_site, ->(this){ where(site_id: this.site_id) }, class_name: "::Sticker::BannerSite", foreign_key: :sticker_banner_id

    validates :title, :user_id, presence: true

    scope :published, -> { where(publish: true) }

    scope :can_share, -> { where(shareable: true) }

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

      banner_site_attrs = attrs.fetch('own_banner_site', {}).except('id', 'type', '@type', 'sticker_banner_id', 'site_id').merge({
        site_id: options[:site_id]
      })
      banner_site_attrs['category_list'] = banner_site_attrs.delete('categories').to_a.map { |category| category['name'] }
      attrs['own_banner_site'] = Sticker::BannerSite.new(banner_site_attrs)

      self.create!(attrs)
    end
  end
end
