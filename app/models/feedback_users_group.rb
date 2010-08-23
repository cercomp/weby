class FeedbackUsersGroup < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :feedback, :foreign_key => "feedback_id"
  belongs_to :group, :foreign_key => "group_id"
end
