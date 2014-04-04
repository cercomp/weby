class MenuAccessibilityComponent < Component
  component_settings :font_size, :contrast
    
  def font_size?
    font_size.blank? ? false : font_size == "1"
  end

  def contrast?
    contrast.blank? ? false :  contrast == "1"
  end
end
