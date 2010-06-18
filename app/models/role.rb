class Role < ActiveRecord::Base
  has_many :roles_users #, :foreign_key => "role_id"
  has_many :users, :through => :roles_users

  has_many :rights_roles
  has_many :rights, :through => :rights_roles

  validates_presence_of :name
end
