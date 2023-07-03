class AlbumTag < ApplicationRecord
  belongs_to :site
  belongs_to :user

  has_and_belongs_to_many :albums

  validates :name, uniqueness: { scope: :site_id }
  validates :slug, uniqueness: { scope: :site_id, allow_blank: true }

  before_create :generate_slug

  def generate_slug
    self.slug = name.parameterize
  end

  def to_param
    slug.present? ? slug : id.to_s
  end
end
