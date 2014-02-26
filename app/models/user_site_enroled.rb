class UserSiteEnroled < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  belongs_to :role
end
