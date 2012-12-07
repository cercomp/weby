class FrontNewsComponent < Component
  component_settings :quant, :avatar_height, :avatar_width, :read_more, :details, :image_size, :new_tab

  validates :quant, presence: true

  alias :_read_more :read_more
  def read_more
    _read_more.blank? ? '1' : _read_more
  end

	alias :_details :details
  def details
    _details.blank? ? '0' : _details
  end

  alias :_image_size :image_size
  def image_size
    _image_size.blank? ? :medium : _image_size
  end

  alias :_avatar_width :avatar_width
  def avatar_width
    _avatar_width.blank? ? "128" : _avatar_width
  end

  alias :_new_tab :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  def image_sizes
    [:medium, :little, :mini, :thumb]
  end
end
