class Feedback < ActiveRecord::Base
  belongs_to :site

  has_and_belongs_to_many :groups

  validates_presence_of :name, :email, :subject, :message
end
