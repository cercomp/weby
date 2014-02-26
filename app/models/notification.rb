class Notification < ActiveRecord::Base
  attr_accessible :title, :body

  belongs_to :user

  validates :title, :body, presence: true

  scope :title_or_body_like, lambda { |text|
    where('LOWER(title) like :text OR LOWER(body) like :text',
          { :text => "%#{text.try(:downcase)}%" })
  }
end
