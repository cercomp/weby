class User < ActiveRecord::Base
  acts_as_authentic

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :first_name, :last_name

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups

  scope :login_or_name_like, lambda { |text|
    where('login like :text OR first_name like :text OR last_name like :text',
           { :text => "%#{name}%" })
  }

  def password_reset!(host)
    reset_perishable_token!
    Notifier.password_reset_instructions(self, host).deliver
  end  
end
