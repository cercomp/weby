class PhotoSliderComponent < Component
  component_settings :photo_ids, :width, :height, :timer, :description, :style, :show_controls, :title

  i18n_settings :title

  alias_method :_photo_ids, :photo_ids
  def photo_ids
    _photo_ids.blank? ? [] : _photo_ids
  end

  alias_method :_width, :width
  def width
    _width.blank? ? '400' : _width
  end

  alias_method :_height, :height
  def  height
    _height.blank? ? '300' : _height
  end

  alias_method :_timer, :timer
  def timer
    _timer.blank? ? '7' : _timer
  end

  alias_method :_description, :description
  def description
    _description.nil? ? '1' : _description
  end

  def show_controls?
    show_controls.blank? ? false : show_controls == '1'
  end

  alias_method :_style, :style
  def style
    _style.blank? ? '1' : _style
  end

  def generate_vector_images
    [].tap do |images|
      photo_ids.each do |image|
        images << Repository.find_by(id: image)
      end
      images.compact!
    end
  end

  def show_description?
    _description.eql?('1')
  end

  def flex_slider_style?
    flex_slider = '1'
    _style.eql?(flex_slider)
  end
end
