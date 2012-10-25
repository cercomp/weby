class WebyTagCloudComponent < Component
  component_settings :cloud_type, :width, :height, :color, :hoover_color, :hoover_type, :speed

  validates :speed, :numericality => {:greater_than => 0}

  def tags(site)
    site.pages.published.tag_counts_on(:categories).map { |tag| tag.name }
  end

  def tag_size(tag,site)
    max_font_size = 35
    min_font_size = 15
    occurs = tag_count(site)
    min_occurs = occurs.min
    max_occurs = occurs.max
    tag_occurs = site.pages.published.tagged_with(tag).count
    tag_occurs = 1 if tag_occurs < 1

    weight = (Math.log(tag_occurs)-Math.log(min_occurs))/(Math.log(max_occurs)-Math.log(min_occurs))
    min_font_size + ((max_font_size-min_font_size)*weight).round
  end

  alias :_width :width
  def width
    _width.blank? ? '300' : _width
  end

  alias :_height :height
  def height
    _height.blank? ? '300' : _height
  end

  alias :_speed :speed
  def speed
    _speed.blank? ? '5' : _speed
  end

  def tag_count(site)
    [].tap do |tag_count|
      site.pages.published.category_counts.each do |tag|
        tag_count << tag.count
      end
    end
  end
end
