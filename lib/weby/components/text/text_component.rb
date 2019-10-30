class TextComponent < Component
  component_settings :body, :html_class

  i18n_settings :body

  validates :html_class, format: { with: /\A[A-Za-z0-9_\-\s]*\z/ }
end
