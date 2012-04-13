class BlankComponent < Component
  initialize_component :body

  validates :body, :presence => true
end
