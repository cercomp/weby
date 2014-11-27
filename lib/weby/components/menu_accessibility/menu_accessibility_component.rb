class MenuAccessibilityComponent < Component
  component_settings :font_size, :contrast, :label_contrast, :label_font_size,
    :extended_accessibility, :additional_information

  i18n_settings :label_contrast, :label_font_size, :additional_information

  after_initialize do
    if new_record?
      default = Weby::Settings::Weby.accessibility_text
      if default.match(/^{/)
        default = eval(default)
      else
        default = {I18n.locale.to_s => default}
      end
      self.additional_information = default
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
end
