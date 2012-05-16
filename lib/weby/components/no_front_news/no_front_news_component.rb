class NoFrontNewsComponent < Component
  initialize_component :quant, :front, :events

  validates :quant, :presence => true
end
