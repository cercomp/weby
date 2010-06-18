class Setting < ActiveRecord::Base
  default_scope :order => "position"
end
