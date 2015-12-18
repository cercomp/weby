module Journal
  class NewsSite < ActiveRecord::Base
    belongs_to :site
    belongs_to :news, class_name: "::Journal::News", foreign_key: :journal_news_id

    acts_as_taggable_on :categories
    acts_as_multisite

    validate :validate_position

    private

    def self.import(attrs, options = {})
      return attrs.each { |attr| import attr, options } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['news-site'] if attrs.key? 'news-site'
      attrs['category_list'] = attrs.delete('categories').to_a.map { |category| category['name'] }
      attrs.except!('id', '@type', 'type', 'created_at', 'updated_at', 'site_id')
      attrs['journal_news_id'] = Import::Application::CONVAR["news"]["#{attrs['journal_news_id']}"]

      self.create!(attrs) if attrs['journal_news_id']

    end

    def validate_position
      self.position = last_front_position + 1
#      self.position = 0 if self.position.nil?
    end

    scope :published, -> { joins(:news).where(journal_news: {status: 'published'}) }
    scope :front, -> { where(front: true) }
    scope :no_front, -> { where(front: false) }
    scope :available, -> { where('journal_news_sites.date_begin_at is NULL OR journal_news_sites.date_begin_at <= :time', time: Time.now) }
    scope :available_fronts, -> { front.where('journal_news_sites.date_end_at is NULL OR journal_news_sites.date_end_at > :time', time: Time.now) }

    # tipos de busca
    # 0 = "termo1 termo2"
    # 1 = termo1 AND termo2
    # 2 = termo1 OR termo2

    def self.uniq_category_counts
      category_counts.each_with_object(Hash.new) do |j, hash|
        name = j.name.upcase
        if hash[name]
          hash[name].count += j.count
        else
          hash[name] = j
        end
        hash
      end.values
    end

    def last_front_position
      @news_site = Journal::NewsSite.where(site: self.site_id).front
      @news_site.maximum('position').to_i
    end

    def validate_date
      self.date_begin_at = Time.now.to_s if date_begin_at.blank?
    end
  end
end
