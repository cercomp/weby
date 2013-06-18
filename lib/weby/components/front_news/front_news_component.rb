class FrontNewsComponent < Component
  component_settings :quant, :avatar_height, :avatar_width, :read_more, :show_author, :show_date, :image_size, :new_tab, :max_char

  validates :quant, presence: true

  alias :_read_more :read_more
  def read_more
    _read_more.blank? ? false : _read_more.to_i == 1
  end

	alias :_show_author :show_author
  def show_author
    _show_author.blank? ? false : _show_author.to_i == 1
  end

  alias :_show_date :show_date
  def show_date
    _show_date.blank? ? false : _show_date.to_i == 1
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
