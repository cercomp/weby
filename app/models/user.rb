class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :confirmable, :lockable, :omniauthable, :omniauth_providers => [:shibboleth]

  attr_accessor :auth

  belongs_to :locale, optional: true

  has_many :views, dependent: :nullify
  has_many :notifications, dependent: :nullify
  has_many :user_login_histories, dependent: :destroy
  has_many :pages, dependent: :restrict_with_error
  has_many :repositories, dependent: :restrict_with_error
  # Extensions relations
  has_many :news, class_name: 'Journal::News', dependent: :restrict_with_error
  has_many :banners, class_name: 'Sticker::Banner', dependent: :restrict_with_error
  has_many :events, class_name: 'Calendar::Event', dependent: :restrict_with_error
  has_many :journal_newsletter_histories
  has_many :auth_sources, dependent: :destroy

  has_and_belongs_to_many :roles

  validates :email, :login, :first_name, :last_name, presence: true
  validates :password, presence: true, on: :create
  validates :email, :login, uniqueness: true
  validates :password, confirmation: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :login, format: { with: /\A[a-z\d_\-\.@]+\z/i }
  validates :password,
            format: {
              with: /(?=.*\d+)(?=.*[A-Z]+)(?=.*[a-z]+)\A.{4,}\z/,
              message: I18n.t('lower_upper_number_chars'),
              allow_blank: true
            }

  before_save :normalize_attributes

  # Returns all user with the name similar to text.
  scope :login_or_name_like, ->(text) {
    if text.present?
      where('LOWER(login) like LOWER(:text) OR
            LOWER(first_name) like LOWER(:text) OR
            LOWER(last_name) like LOWER(:text) OR
            LOWER(email) like LOWER(:text)',  text: "%#{text}%")
    end
  }

  # Returns all local_admin users.
  scope :local_admin, ->(id) {
    select('DISTINCT users.* ')
      .joins('LEFT JOIN roles_users ON roles_users.user_id = users.id
              LEFT JOIN roles ON roles.id = roles_users.role_id')
      .where(['roles.permissions = ? AND roles.site_id = ?', "Admin", id])
  }

  # Returns all admin users.
  scope :admin, -> { where(is_admin: true) }

  # Returns all users that are no admins.
  scope :no_admin, -> { where(is_admin: false) }

  # Returns all user that have a role in site_id.
  scope :by_site, ->(id) {
    select('DISTINCT users.* ')
      .joins('LEFT JOIN roles_users ON roles_users.user_id = users.id
              LEFT JOIN roles ON roles.id = roles_users.role_id')
      .where(['roles.permissions != ? AND roles.site_id = ?', "Admin", id])
  }

  # Returns all users that have confirmed their registration.
  scope :actives, -> { where('confirmed_at IS NOT NULL') }

  scope :global_role, -> {
    joins(:roles).distinct.where(roles: {site_id: nil})
  }

  scope :by_no_site, ->(id) {
    where("not exists (#{
      Role.joins('INNER JOIN roles_users ON
                  roles_users.role_id = roles.id AND
                  users.id = roles_users.user_id')
        .where(site_id: id).to_sql
    })")
  }

  def to_s
    name_or_login
  end

  def name_or_login
    first_name ? fullname : login
  end

  def fullname
    first_name ? ("#{first_name} #{last_name}") : ''
  end

  def email_address_with_name
    first_name ? "#{first_name} #{last_name} <#{email}>" : "#{login} <#{email}>"
  end

  def unread_notifications_array
    unread_notifications.to_s.split(',').map { |notif| notif.to_i }
  end

  def append_unread_notification(notification)
    return unless notification
    new_unread_notifications = unread_notifications_array.append(notification.id).join(',')
    update_attribute(:unread_notifications, new_unread_notifications)
  end

  def remove_unread_notification(notification = nil)
    unread = unread_notifications_array
    notification ? unread.delete(notification.id) : unread.clear
    update_attribute(:unread_notifications, unread.join(','))
  end

  def is_local_admin?(id_site)
    User.local_admin(id_site).find_by(id: id)
  end

  def has_read?(notification)
    @unread ||= unread_notifications_array
    @unread.exclude? notification.id
  end

  def has_role_in?(site)
    return true if self.is_admin?
    sites.include?(site) || global_roles.any?
  end

  def sites
    Site.active.where(id: roles.map { |role| role.site_id }.uniq)
  end

  # Returns the user's global roles
  def global_roles
    #roles.where(site_id: nil)
    roles.select{|role| role.site_id.blank? }
  end

  def roles_in site
    roles.select{|role| role.site_id == site.id }
  end

  def record_login user_agent, ip
    ua = UserAgent.parse(user_agent)

    UserLoginHistory.create(
      user_id: id,
      login_ip: ip,
      browser: ua.browser,
      platform: "#{ua.platform} #{ua.os}"
    )
  end

  # NOTE Routine used to manage the authlogic's password pattern using devise.
  # When the user have an encripted password using the authlogic's hash
  # it is generated an new password using the devise's hash, and then authenticate
  alias_method :devise_valid_password?, :valid_password?
  def valid_password?(password)
    super(password)
  rescue BCrypt::Errors::InvalidHash
    digest = "#{password}#{password_salt}"
    20.times { digest = Digest::SHA512.hexdigest(digest) }
    return false unless digest == encrypted_password
    logger.info "User #{email} is using the old password hashing method, updating attribute."
    self.password = password
    true
  end

  # Authenticates using login or email
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:auth)
      where(conditions).where(['lower(login) = :value OR lower(email) = :value', { value: login.downcase }]).first
    else
      super
    end
  end

  def ldap_auth_source
    auth_sources.ldap.first
  end

  # !!! use this method wisely
  def clear_password!
    self.update!(password: "A#{SecureRandom.hex(32)}")
  end

  private

  def normalize_attributes
    email.downcase!
  end
end
