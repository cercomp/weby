class App < ApplicationRecord
  validates :name, :code, presence: true

  has_secure_token :api_token

  scope :name_like, ->(text) {
    if text.present?
      where('LOWER(name) like LOWER(:text) OR
            LOWER(code) like LOWER(:text)',  text: "%#{text}%")
    end
  }

end
