class MenuAccessibilityComponent < Component
  component_settings :font_size, :contrast, :own_contrast, :css_own_contrast
    
  def font_size?
    font_size.blank? ? false : font_size == "1"
  end

  def contrast?
    contrast.blank? ? false :  contrast == "1"
  end

  def own_contrast?
    own_contrast.blank? ? false :  own_contrast == "1"
  end
end
