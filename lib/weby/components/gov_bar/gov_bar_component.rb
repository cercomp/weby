class GovBarComponent < Component
  initialize_component :background

  validates :background, :presence => true
end
