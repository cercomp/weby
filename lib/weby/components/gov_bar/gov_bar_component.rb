class GovBarComponent < SiteComponent
  initialize_component :background

  validates :background, :presence => true
end
