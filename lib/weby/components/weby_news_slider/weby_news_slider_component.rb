class WebyNewsSliderComponent < Component
  component_settings :news_category, :width, :height, :quantity

  def pages(site)
    news_category.blank? ?
      site.pages.where('repository_id is not null').limit(5) :
      site.pages.tagged_with(news_category).where('repository_id is not null')
  end

  alias :_width :width
  def width
    _width.blank? ? '400' : _width
  end

  alias :_height :height
  def height
    _height.blank? ? '300' : _height
  end

  alias :_quantity :quantity
  def quantity
    _quantity.blank? ? '5' : _quantity
  end
end
