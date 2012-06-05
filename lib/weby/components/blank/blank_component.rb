class BlankComponent < Component
  component_settings :body

  validates :body, :presence => true
end
