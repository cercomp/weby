class Role < ActiveRecord::Base
  
  scope :globals, where(site_id: nil)

  validates_presence_of :name

  # Removido para utilizar a relação ternária entre roles e sites
    #has_many :roles_users #, :foreign_key => "role_id"
    #has_many :users, :through => :roles_users

  belongs_to :site

  has_and_belongs_to_many :users

  has_many :rights_roles
  has_many :rights, :through => :rights_roles

  def permissions_hash
    self.permissions.present? ? eval(self.permissions.to_s) : {}
  end

  default_scope lambda { where(deleted: false) }
  scope :deleted, lambda { where(deleted: true) }
end
