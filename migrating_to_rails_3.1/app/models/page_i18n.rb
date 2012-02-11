class PageI18n < ActiveRecord::Base
  scope :by_locale, lambda { |locale|
    where(["locale_id = ?", locale.id])
  }

  belongs_to :page
  belongs_to :locale

  validates_presence_of :title
end
