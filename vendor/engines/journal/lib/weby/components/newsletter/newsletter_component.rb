class NewsletterComponent < Component
  component_settings :text, :delete_text, :group, :send_as, :subject, :hide_form,
                     :button_text, :report_title, :report_subtitle, :report_logo,
                     :position_logo

  i18n_settings :text, :delete_text, :button_text, :send_as, :report_title, :report_subtitle

  alias_method :_group, :group
  def group
    _group.blank? ? "[all]" : _group
  end

  def logo
    Repository.find(report_logo) if report_logo.present?
  end

  alias_method :_position_logo, :position_logo
  def position_logo
    _position_logo.blank? ? position_logo_list[0] : _position_logo
  end

  def position_logo_list
    %w(left right)
  end
end
