class MenuAccessibilityComponent < Component
  component_settings :font_size, :contrast, :label_contrast, :label_font_size,
    :extended_accessibility, :additional_information, :template,
    :content_anchor, :menu_anchor, :search_anchor, :information_access_url

  i18n_settings :label_contrast, :label_font_size, :additional_information

  after_initialize do
    if new_record?
      if default = Weby::Settings::Weby.accessibility_text
        self.additional_information = default.match(/^{/) ?
          eval(default) :
          {I18n.locale.to_s => default}
      end
    end
  end

  def font_size?
    font_size.blank? ? true : font_size == '1'
  end

  def contrast?
    contrast.blank? ? true :  contrast == '1'
  end

  def extended_accessibility?
    extended_accessibility.blank? ? false : extended_accessibility == '1'
  end

  def default_alias
    I18n.t("menu_accessibility.views.form.#{extended_accessibility? ? 'extended' : 'basic'}")
  end

  def template_options
    %w(default bar)
  end
end
