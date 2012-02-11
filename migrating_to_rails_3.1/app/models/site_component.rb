class SiteComponent < ActiveRecord::Base
  before_create { self.publish ||= true }
  belongs_to :site
end
