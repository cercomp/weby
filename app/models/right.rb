class Right < ActiveRecord::Base
  has_many :rights_roles
  has_many :roles, :through => :rights_roles
  
  validates_presence_of :name, :controller, :action
end
