class Role < ActiveRecord::Base
  belongs_to :site

  has_and_belongs_to_many :users

  validates :name, presence: true

  scope :globals, -> { where(site_id: nil) }
  scope :no_local_admin, -> { where("permissions != 'Admin'") }

  def permissions_hash
    permissions.present? ? eval(permissions.to_s) : {}
  end
end
