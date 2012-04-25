class BannerSideComponent < Component
  initialize_component :category

  validates :category, :presence => true
end
