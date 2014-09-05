module Sticker
  class Banner < ActiveRecord::Base
    acts_as_taggable_on :categories

    belongs_to :page
    belongs_to :repository
    belongs_to :user
    belongs_to :site

    validates :title, :user_id, presence: true

    validate :validate_date

    scope :published, -> {
      where("publish = true AND (date_begin_at <= :time AND
           (date_end_at is NULL OR date_end_at > :time))",  time: Time.now)
    }

    scope :titles_or_texts_like, ->(str) {
      where("LOWER(title) like :str OR
           LOWER(text) like :str",  str: "%#{str.try(:downcase)}%")
    }

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['banners'] if attrs.key? 'banners'

      attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')

      attrs['repository_id'] = Import::Application::CONVAR["repository"]["#{attrs['repository_id']}"]
      attrs['user_id'] = options[:author] unless User.unscoped.find_by_id(attrs['user_id'])

      categories = attrs.delete('categories')

      newbanner = self.create!(attrs)

      categories.each do |category|
        newbanner.category_list << category['name']
        newbanner.save
      end

    end

    private

    def validate_date
      self.date_begin_at = Time.now.to_s if date_begin_at.blank?
    end
  end
end
