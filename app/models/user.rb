class User < ActiveRecord::Base
  acts_as_authentic

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :first_name, :last_name

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups
  
  def self.search(search, page)
    paginate :per_page => 20, :page => page, :conditions => ['login like ? OR first_name like ? OR last_name like ?', "%#{search}%","%#{search}%","%#{search}%"], :order => 'id DESC'
  end
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end  
end
