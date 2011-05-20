class SiteComponent < ActiveRecord::Base
  default_scope :order => 'position,place_holder ASC'

  belongs_to :site
end
