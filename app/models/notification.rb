class Notification < ApplicationRecord
  belongs_to :user

  validates :title, :body, presence: true

  scope :title_or_body_like, ->(text) {
    where('LOWER(title) like :text OR LOWER(body) like :text',
          text: "%#{text.try(:downcase)}%")
  }
end
