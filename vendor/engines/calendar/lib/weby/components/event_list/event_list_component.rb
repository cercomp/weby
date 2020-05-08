class EventListComponent < Component
  component_settings :quant, :avatar_height, :avatar_width, :read_more, :group_by,
                     :image_size, :max_char, :filter_by, :label,
                     :link_to_all, :template, :date_format, :html_class,
                     :source, :sel_site

  i18n_settings :label, :link_to_all

  validates :quant, presence: true, numericality: { greater_than: 0 }
  validates :sel_site, presence: true, if: ->{ source == 'selected' }

  def source_site
    if source == 'selected' && sel_site.present?
      Site.active.find_by(id: sel_site)
    end
  end

  def get_events(curr_site, page_param)
    if source == 'selected'
      site = Site.active.find_by(id: sel_site)
      site ? events(site, page_param) : Calendar::Event.none
    else
      events(curr_site, page_param)
    end
  end

  def events(site, page_param)
    direction = 'desc'
    result = site.events.includes(:image, :i18ns).upcoming.order('begin_at asc, id asc')
    result = result.tagged_with(filter_by.mb_chars.downcase.to_s, any: true) if filter_by.present?
    result.page(page_param).per(quant)
  end
  private :events

  alias_method :_read_more, :read_more
  def read_more
    _read_more.blank? ? false : _read_more.to_i == 1
  end

  alias_method :_group_by, :group_by
  def group_by
    _group_by.blank? ? false : _group_by.to_i == 1
  end

  alias_method :_image_size, :image_size
  def image_size
    _image_size.blank? ? :m : _image_size
  end

  alias_method :_quant, :quant
  def quant
    _quant.blank? ? 5 : (_quant.to_i == 0 ? 1 : _quant.to_i)
  end

  def date_formats
    [:full, :short, :two_dates]
  end

  def template_types
    [:basic, :front]
  end

  def image_sizes
    [:m, :l, :i, :t]
  end

  def order_by
    [:basic, :front]
  end

  def source_options
    ['own', 'selected']
  end
end
