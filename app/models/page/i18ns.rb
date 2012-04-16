class Page::I18ns < ActiveRecord::Base
  belongs_to :page

  belongs_to :locale
  validates :locale_id,
    presence: true

  validates :title,
    presence: true
end
