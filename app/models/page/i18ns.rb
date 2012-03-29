class Page::I18ns < ActiveRecord::Base
  belongs_to :page
  validates :page,
    presence: true

  belongs_to :locale
  validates :locale_id,
    presence: true

  validates :title,
    presence: true
end
