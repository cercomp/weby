class AuthSource < ActiveRecord::Base
  belongs_to :user

  validates :source_type, uniqueness: { scope: :user_id }
end
