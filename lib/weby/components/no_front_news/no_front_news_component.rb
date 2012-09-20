class NoFrontNewsComponent < Component
  component_settings :quant, :front, :events

  validates :quant, presence: true
end
