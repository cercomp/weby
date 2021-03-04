class AuthSource < ApplicationRecord
  belongs_to :user

  validates :source_type, uniqueness: { scope: :user_id }

  scope :ldap, -> { where(source_type: :ldap) }
end
