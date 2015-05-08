class NewsletterComponent < Component
  component_settings :text, :text_delete, :group, :email, :subject, :new_window

  alias_method :_group, :group
  def group
    _group.blank? ? "[all]" : _group
  end
end
