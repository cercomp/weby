class EventListComponent < Component
  component_settings :quant, :avatar_height, :avatar_width, :read_more,
                     :image_size, :max_char, :filter_by, :label,
                     :link_to_all, :template

  i18n_settings :label, :link_to_all

  validates :quant, presence: true

  def get_events(site, page_param)
    filter_by.blank? ? events(site, page_param) : events(site, page_param).tagged_with(filter_by.mb_chars.downcase.to_s, any: true)
  end

  def events(site, page_param)
    direction = 'desc'
    events = Calendar::Event.where(site_id: site.id).includes(:image).upcoming
      .order("begin_at asc, id asc").page(page_param).per(quant)
  end
  private :events

  alias_method :_read_more, :read_more
  def read_more
    _read_more.blank? ? false : _read_more.to_i == 1
  end

  alias_method :_image_size, :image_size
  def image_size
    _image_size.blank? ? :m : _image_size
  end

  alias_method :_quant, :quant
  def quant
    _quant.blank? ? 5 : _quant.to_i
  end

  def template_types
    [:basic, :front]
  end

  def image_sizes
    [:m, :l, :i, :t]
  end
end
