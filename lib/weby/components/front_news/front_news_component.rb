class FrontNewsComponent < Component
  initialize_component :quant

  validates :quant, :presence => true
end
