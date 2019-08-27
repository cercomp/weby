class ComponentsGroupComponent < Component
  component_settings :html_class

  validates :html_class, format: { with: /\A[A-Za-z0-9_\-\s]*\z/ }
end
