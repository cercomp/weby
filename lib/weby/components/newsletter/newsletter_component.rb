class NewsletterComponent < Component
  component_settings :text, :group

  alias_method :_group, :group
  def group
    _group.blank? ? "[all]" : _group
  end
end
