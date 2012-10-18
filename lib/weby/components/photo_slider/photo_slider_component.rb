class PhotoSliderComponent < Component
  component_settings :photo_ids, :width, :height, :timer, :description

  alias :_photo_ids :photo_ids
  def photo_ids
    _photo_ids.blank? ? [] : _photo_ids 
  end

  alias :_width :width
  def width
    _width.blank? ? '400' : _width
  end

  alias :_height :height
  def  height
    _height.blank? ? '300' : _height 
  end

  alias :_timer :timer
  def timer 
    _timer.blank? ? '7' : _timer 
  end

  alias :_description :description
  def description
    _description.nil? ? "1" : _description
  end

  def generate_vector_images
    [].tap do |images|
    photo_ids.each do |image|
      images<<Repository.find(image)
    end
    images.compact!
    end
  end

  def show_description?
    _description.eql?("1")    
  end

end
