module Sticker
  class BannerSite < Sticker::ApplicationRecord
    belongs_to :site
    belongs_to :banner, class_name: "::Sticker::Banner", foreign_key: :sticker_banner_id

    acts_as_ordered_taggable_on :categories

    validate :validate_position

    def category_list_before_type_cast
      category_list.to_s
    end

    scope :available, -> { where('sticker_banners.date_begin_at <= :time AND (sticker_banners.date_end_at is NULL OR sticker_banners.date_end_at > :time)', time: Time.current) }
    scope :published, -> { where(sticker_banners: {publish: true}) }
    scope :titles_or_texts_like, ->(str) {
      where("LOWER(sticker_banners.title) like :str OR
           LOWER(sticker_banners.text) like :str",  str: "%#{str.try(:downcase)}%")
    }

    private

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['banner-site'] if attrs.key? 'banner-site'
      attrs['category_list'] = attrs.delete('categories').to_a.map { |category| category['name'] }
      attrs.except!('id', '@type', 'type', 'created_at', 'updated_at', 'site_id')
      attrs['sticker_banner_id'] = Import::Application::CONVAR["banners"]["#{attrs['sticker_banner_id']}"]

      self.create!(attrs) if attrs['sticker_banner_id']
    end

    def validate_position
      self.position = last_position + 1 if self.position.nil?
      #self.position = 0 if self.position.nil?
    end

    def last_position
      Sticker::BannerSite.where(site_id: self.site_id).maximum(:position).to_i
    end

  end
end
