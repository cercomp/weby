class User < ActiveRecord::Base
  acts_as_authentic

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end  

  # Removido para utilizar a relação ternária entre roles e sites
    #has_many :roles_users #, :foreign_key => "user_id"
    #has_many :roles, :through => :roles_users

    #has_many :sites_users #, :foreign_key => "user_id"
    #has_many :sites, :through => :sites_users

  has_many :user_site_enroled, :dependent => :destroy
  has_many :sites, :through => :user_site_enroled
  has_many :roles, :through => :user_site_enroled

  #has_many :group, :through => :feedback_users_group
  #has_many :feedback, :through => :feedback_users_group
  #has_many :feedback_users_group
  has_and_belongs_to_many :groups
end
