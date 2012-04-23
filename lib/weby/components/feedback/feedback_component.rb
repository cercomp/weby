class FeedbackComponent < Component
  initialize_component :label

  validates :label, :presence => true
end
