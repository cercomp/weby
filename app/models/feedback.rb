class Feedback < ActiveRecord::Base
  has_many :feedback_users_group
  #has_many :user, :through => :feedback_users_group
  #has_many :group, :through => :feedback_users_group

  belongs_to :site
end
