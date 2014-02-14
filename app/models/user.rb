# coding: utf-8
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :confirmable, :lockable

  attr_accessible :login, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :phone, :mobile, :locale_id, :confirmed_at,
                  :is_admin

  validates_presence_of :email, :login, :first_name, :last_name
  validates_presence_of :password, on: :create

  validates_uniqueness_of :email, :login

  validates_confirmation_of :password

  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_format_of :login, with: /^[a-z\d_\-\.@]+$/i
	validates_format_of :password, with: /(?=.*\d+)(?=.*[A-Z]+)(?=.*[a-z]+)^.{4,}$/,
	                    allow_blank: true, message: I18n.t("lower_upper_number_chars")

  before_save { |user| user.email.downcase! }

  has_and_belongs_to_many :roles

  belongs_to :locale

  has_many :views, dependent: :nullify
  has_many :notifications, dependent: :nullify
  has_many :user_login_histories, dependent: :nullify
  has_many :pages, foreign_key: :author_id, dependent: :restrict

  scope :login_or_name_like, lambda { |text|
    where('LOWER(login) like :text OR LOWER(first_name) like :text OR LOWER(last_name) like :text OR LOWER(email) like :text',
          { :text => "%#{text.try(:downcase)}%" })
  }

  scope :admin, where(:is_admin => true)
  scope :no_admin, where(:is_admin => false)

  scope :by_site, lambda { |site_id|
    select("DISTINCT users.* ").
    joins('LEFT JOIN roles_users ON roles_users.user_id = users.id
           LEFT JOIN roles ON roles.id = roles_users.role_id').
    where(["roles.site_id = ?", site_id])           
  }

  scope :actives, where('confirmed_at IS NOT NULL')

  scope :global_role, lambda { 
    select("DISTINCT users.* ").
    joins('INNER JOIN roles_users ON roles_users.user_id = users.id 
           INNER JOIN roles ON roles.id = roles_users.role_id').
    where(["roles.site_id IS NULL"])
  }

  scope :by_no_site, lambda { |site_id|
    where "not exists (#{
      Role.joins('INNER JOIN roles_users ON 
      roles_users.role_id = roles.id AND users.id = roles_users.user_id').
      where(:site_id => site_id).to_sql
    })" 
  }

  def to_s
   name_or_login
  end

  def name_or_login
    self.first_name ? self.fullname : self.login
  end

  def fullname
    self.first_name ? ("#{self.first_name} #{self.last_name}") : ""
  end

  def email_address_with_name
    self.first_name ? "#{self.first_name} #{self.last_name} <#{self.email}>" : "#{self.login} <#{self.email}>"
  end

  def unread_notifications_array
    self.unread_notifications.to_s.split(',').map{|notif| notif.to_i}
  end

  def append_unread_notification notification
    return unless notification
    self.update_attribute(:unread_notifications, unread_notifications_array.append(notification.id).join(','))
  end

  def remove_unread_notification notification=nil
    unread = self.unread_notifications_array
    notification ? unread.delete(notification.id) : unread.clear
    self.update_attribute(:unread_notifications, unread.join(','))
  end

  def has_read? notification
    @unread ||= unread_notifications_array
    !@unread.include? notification.id
  end
  
  def has_role_in? site
    return true if self.is_admin?
    self.sites.include?(site) or self.global_roles.any?
  end

  def sites
    Site.where(id: self.roles.map{|role| role.site_id}.uniq)
  end

  # Pega os papeis globais do usuário
  def global_roles
    self.roles.where(site_id: nil)
  end

  # NOTE Rotina para trabalhar com o padrão de senha do authlogic no devise.
  # Quando um usuário possui a senha encriptada usando o hash do authlogic
  # é gerada uma nova senha encriptada com o hash do devise, atualiza e autentica 
  alias :devise_valid_password? :valid_password?
  def valid_password?(password)
    begin
      super(password)
    rescue BCrypt::Errors::InvalidHash
      digest = "#{password}#{password_salt}"
      20.times { digest = Digest::SHA512.hexdigest(digest) }
      return false unless digest == encrypted_password
      logger.info "User #{email} is using the old password hashing method, updating attribute."
      self.password = password
      true
    end
  end
end
