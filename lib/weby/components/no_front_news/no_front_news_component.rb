class NoFrontNewsComponent < Component
  initialize_component :quant, :front

  validates :quant, :presence => true
end
