module Sticker
  class Banner < Sticker::ApplicationRecord
    belongs_to :target, polymorphic: true, optional: true
    belongs_to :repository, optional: true
    belongs_to :user
    belongs_to :site

    has_many :banner_sites, foreign_key: :sticker_banner_id, class_name: "::Sticker::BannerSite", inverse_of: :banner, dependent: :destroy
    has_many :sites, through: :banner_sites
    has_one :own_banner_site, ->(this){ where(site_id: this.site_id) }, class_name: "::Sticker::BannerSite", foreign_key: :sticker_banner_id

    validates :title, :user_id, presence: true
    validate :validate_date

    scope :available, -> { where('sticker_banners.date_begin_at <= :time AND (sticker_banners.date_end_at is NULL OR sticker_banners.date_end_at > :time)', time: Time.current) }
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

    def self.new_or_clone id, params={}
      if id.present?
        site_id = current_scope.values.fetch(:where, {}).to_h['site_id']
        banner_site = Sticker::BannerSite.where(site_id: (site_id || -1)).find_by(id: id)
        if banner_site && (banner = banner_site.banner)
          banner = current_scope.new({
            repository_id: banner.repository_id,
            size: banner.size,
            width: banner.width,
            height: banner.height,
            title: banner.title,
            text: banner.text,
            publish: banner.publish,
            shareable: banner.shareable,
            url: banner.url,
            target: banner.target,
            new_tab: banner.new_tab,
            date_begin_at: banner.date_begin_at,
            date_end_at: banner.date_end_at
          })
          banner.banner_sites.build(site_id: banner.site_id, category_list: banner_site.category_list)
          return banner
        end
      end
      #default
      banner = current_scope.new(params)
      banner.banner_sites.build(site_id: banner.site_id)
      banner
    end

    private

    def validate_date
      self.date_begin_at = Time.current if date_begin_at.blank?
    end

  end
end
