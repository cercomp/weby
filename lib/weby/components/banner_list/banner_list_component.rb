class BannerListComponent < Component
  component_settings :category, :orientation

  validates :category, presence: true
end
