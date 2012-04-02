class Page::I18ns < ActiveRecord::Base
  belongs_to :page, include: :author
  validates :page,
    presence: true

  belongs_to :locale
  validates :locale_id,
    presence: true

  validates :title,
    presence: true

  delegate :date_begin_at, :date_end_at, :status, :author,
    :url, :site_id, :source, :kind, :local, :event_begin,
    :event_end, :event_email, :subject, :align, :type,
    :created_at, :updated_at, :repository_id, :size,
    :publish, :front, :position, :category_list, to: :page
end
