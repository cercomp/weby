class Role < ApplicationRecord
  belongs_to :site, optional: true

  has_and_belongs_to_many :users

  validates :name, presence: true

  scope :globals, -> { where(site_id: nil) }
  scope :no_local_admin, -> { where("permissions != 'Admin' OR permissions is null") }

  def permissions_hash
    permissions.present? ? eval(permissions.to_s) : {}
  end
end
