class AlbumTag < ApplicationRecord
  belongs_to :site
  belongs_to :user

  has_and_belongs_to_many :albums

  validates :name, uniqueness: { scope: :site_id }
end
