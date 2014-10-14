class WebyTagCloudComponent < Component
  component_settings :cloud_type, :width, :height, :color, :hoover_color, :hoover_type, :speed

  validates :speed, numericality: { greater_than: 0 }

  def tags(site)
    Journal::News.where(site_id: site.id).available.uniq_category_counts.map { |tag| tag.name }
  end

  def tag_size(tag, site)
    max_font_size = 35
    min_font_size = 15
    occurs = tag_count(site)
    min_occurs = occurs.min
    max_occurs = occurs.max
    tag_occurs = Journal::News.where(site_id: site.id).published.tagged_with(tag.to_s.mb_chars.downcase.to_s, any: true).length

    tag_occurs = 1 if tag_occurs < 1
    diff = Math.log(max_occurs) - Math.log(min_occurs)
    diff = 1 if diff < 1

    weight = (Math.log(tag_occurs) - Math.log(min_occurs)) / diff
    min_font_size + ((max_font_size - min_font_size) * weight).round
  end

  alias_method :_width, :width
  def width
    _width.blank? ? '300' : _width
  end

  alias_method :_height, :height
  def height
    _height.blank? ? '300' : _height
  end

  alias_method :_speed, :speed
  def speed
    _speed.blank? ? '5' : _speed
  end

  def tag_count(site)
    Journal::News.where(site_id: site.id).published.uniq_category_counts.map { |tag| tag.count }
  end
end
