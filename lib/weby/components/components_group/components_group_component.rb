class ComponentsGroupComponent < Component
  component_settings :html_class

  validates_format_of :html_class, with: /\A[A-Za-z0-9_\-]\z$/
end
