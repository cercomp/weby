class Feedback < ActiveRecord::Base

  belongs_to :site

  has_and_belongs_to_many :groups

  validates :name, :presence => true

end
