class WebyTagCloudComponent < Component
  component_settings :cloud_type, :width, :height, :color, :hoover_color, :font_size

  def tags(site)
    site.pages.published.tag_counts_on(:categories).map { |tag| tag.name }
  end

  alias :_width :width
  def width
    _width.blank? ? '300' : _width
  end

  alias :_height :height
  def height
    _height.blank? ? '300' : _height
  end

  alias :_font_size :font_size
  def font_size
    _font_size.blank? ? '15' : _font_size
  end

end
