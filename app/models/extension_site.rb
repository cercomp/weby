class ExtensionSite < ActiveRecord::Base
  belongs_to :site
  attr_accessible :name
end
