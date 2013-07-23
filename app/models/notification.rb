class Notification < ActiveRecord::Base
  attr_accessible :title, :body 

  belongs_to :user

  validates :title, :body, presence: true
end
