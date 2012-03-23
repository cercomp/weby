class PageI18n < ActiveRecord::Base
  scope :by_locale, lambda { |locale|
    where(["locale_id = ?", locale.id])
  }

  belongs_to :page
  belongs_to :locale

  validate :title, presence: true
  validate :locale_id, presence: true

  def title
    super.gsub("'","´") if super
  end
end
