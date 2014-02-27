class Banner < ActiveRecord::Base
  acts_as_taggable_on :categories

  scope :published, lambda {
    where("publish = true AND (date_begin_at <= :time AND
                          (date_end_at is NULL OR date_end_at > :time))",
                          { :time => Time.now })
  }

  scope :titles_or_texts_like, lambda { |str|
    where("LOWER(title) like :str OR LOWER(text) like :str", { :str => "%#{str.try(:downcase)}%"})}

  belongs_to :page
  belongs_to :repository
  belongs_to :user
  belongs_to :site

  validates :title, :user_id, presence: true

  validate :validate_date

  def validate_date
    if self.date_begin_at.blank?
      self.date_begin_at = Time.now.to_s
    end
  end

  def self.import attrs, options={}
    return attrs.each{|attr| self.import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['banners'] if attrs.has_key? 'banners'

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')

    attrs['repository_id'] = ''
    attrs['user_id'] = options[:author] unless User.unscoped.find_by_id(attrs['user_id'])

    extension = self.create!(attrs)
  end

  private :validate_date
end
