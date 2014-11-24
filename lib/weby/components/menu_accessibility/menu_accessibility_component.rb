class MenuAccessibilityComponent < Component
  component_settings :font_size, :contrast, :label_contrast, :label_font_size,
    :extended_accessibility, :additional_information

  i18n_settings :label_contrast, :label_font_size, :additional_information

  def font_size?
    font_size.blank? ? true : font_size == '1'
  end

  def contrast?
    contrast.blank? ? true :  contrast == '1'
  end

  def extended_accessibility?
    extended_accessibility.blank? ? false : extended_accessibility == '1'
  end
end
