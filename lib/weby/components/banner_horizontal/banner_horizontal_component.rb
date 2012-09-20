class BannerHorizontalComponent < Component
  component_settings :category

  validates :category, presence: true
end
