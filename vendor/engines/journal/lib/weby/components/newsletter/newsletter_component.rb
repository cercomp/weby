class NewsletterComponent < Component
  component_settings :text, :delete_text, :group, :send_as, :subject, :hide_form,
                     :button_text, :report_title, :report_subtitle, :report_logo

  alias_method :_group, :group
  def group
    _group.blank? ? "[all]" : _group
  end
end
