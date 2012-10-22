class WebyNewsSliderComponent < Component
  component_settings :news_category, :width, :height, :quantity, :timer

  def pages(site)
    news_category.blank? ?
      site.pages.available.front.where('repository_id is not null').order('position desc').limit(quantity) :
      site.pages.available.tagged_with(news_category).where('repository_id is not null').order('position desc')
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

  alias :_timer :timer
  def timer
    _timer.blank? ? '7' : _timer
  end

  def default_alias
    self.news_category
  end
end
