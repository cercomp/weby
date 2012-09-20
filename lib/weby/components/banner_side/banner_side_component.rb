class BannerSideComponent < Component
  component_settings :category

  validates :category, presence: true
end
