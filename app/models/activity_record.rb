class ActivityRecord < ActiveRecord::Base
  belongs_to :loggeable, polymorphic: true
  # attr_accessible :title, :body
end
