class MenuAccessibilityComponent < Component
  component_settings :font_size, :contrast, :label_contrast, :label_font_size,
    :extended_accessibility, :software_for_the_visually_impaired, :related_links

  i18n_settings :label_contrast, :label_font_size, :software_for_the_visually_impaired, :related_links

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
