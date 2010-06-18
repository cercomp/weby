class User < ActiveRecord::Base
  acts_as_authentic

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end  

  has_many :roles_users #, :foreign_key => "user_id"
  has_many :roles, :through => :roles_users
end
