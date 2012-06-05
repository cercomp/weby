class FrontNewsComponent < Component
  component_settings :quant

  validates :quant, :presence => true
end
