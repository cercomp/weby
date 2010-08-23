class Group < ActiveRecord::Base
  has_many :feedback_users_group
  has_many :user, :through => :feedback_users_group
  has_many :feedback, :through => :feedback_users_group
end
