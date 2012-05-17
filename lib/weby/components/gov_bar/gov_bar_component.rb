class GovBarComponent < Component
  component_settings :background

  validates :background, :presence => true
end
