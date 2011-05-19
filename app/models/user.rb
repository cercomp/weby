class User < ActiveRecord::Base
  acts_as_authentic

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :first_name, :last_name

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups

  scope :login_or_name_like, lambda { |text|
    where('login like :text OR first_name like :text OR last_name like :text',
          { :text => "%#{text}%" })
  }

  scope :admin, where(:is_admin => true)
  scope :no_admin, where(:is_admin => false)

  scope :by_site, lambda { |site_id, *admin|
    joins('LEFT JOIN roles_users ON roles_users.user_id = users.id 
           LEFT JOIN roles ON roles.id = roles_users.role_id').
           where(["roles.site_id = ? or users.is_admin = ?", site_id, admin])
  }

  scope :by_no_site, lambda { |site_id|
    where "not exists (#{
      Role.joins('INNER JOIN roles_users ON 
      roles_users.role_id = roles.id AND users.id = roles_users.user_id').
      where(:site_id => site_id).to_sql
    })" 
  }

  def name_or_login
    self.first_name ? ("#{self.first_name} #{self.last_name}") : self.login
  end

  def password_reset!(host)
    reset_perishable_token!
    Notifier.password_reset_instructions(self, host).deliver
  end  

end
