class UserLoginHistory < ActiveRecord::Base
  belongs_to :user

  scope :by_user, lambda { |id|
    where(user_id: id)
  }

end
