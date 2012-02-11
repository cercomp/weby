class SiteComponent < ActiveRecord::Base
  before_create { self.publish ||= true }
  default_scope :order => 'position,place_holder ASC'

  belongs_to :site
end
