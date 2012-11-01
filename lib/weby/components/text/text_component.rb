class TextComponent < Component
  component_settings :body, :html_class

  validates_format_of :html_class, :with => /^[A-Za-z0-9_\-]*$/
end
