class Role < ActiveRecord::Base
  # Removido para utilizar a relação ternária entre roles e sites
    #has_many :roles_users #, :foreign_key => "role_id"
    #has_many :users, :through => :roles_users

  has_many :user_site_enroled, :dependent => :destroy
  has_many :sites, :through => :user_site_enroled
  has_many :roles, :through => :user_site_enroled

  has_many :rights_roles
  has_many :rights, :through => :rights_roles

  validates_presence_of :name
end
