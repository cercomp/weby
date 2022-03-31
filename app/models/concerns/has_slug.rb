module HasSlug
  extend ActiveSupport::Concern

  included do
    validates :slug, uniqueness: { scope: :site_id, allow_blank: true }
  end

  def generate_slug
    self.slug = (slug.blank? ? title : slug).parameterize
  end

  def to_param
    slug.blank? ? "#{id}-#{title}".parameterize : slug
  end

end
