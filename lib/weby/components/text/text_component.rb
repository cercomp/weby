class TextComponent < Component
  component_settings :body, :html_class

  i18n_settings :body

  validates_format_of :html_class, with: /^[A-Za-z0-9_\-]*$/
end
