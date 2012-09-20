class FeedbackComponent < Component
  component_settings :label

  validates :label, presence: true
end
