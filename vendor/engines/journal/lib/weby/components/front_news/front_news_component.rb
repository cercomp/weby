class FrontNewsComponent < Component
  component_settings :quant, :avatar_height, :avatar_width, :read_more, :tag_as_label, :show_author,
                     :show_date, :date_format, :which_date, :image_size, :new_tab, :max_char, :filter_by, :label,
                     :link_to_all, :show_tags, :order_by, :hide_filtered_tags, :html_class

  i18n_settings :label, :link_to_all

  validates :quant, presence: true, numericality: { greater_than: 0 }
  validates :html_class, format: { with: /\A[A-Za-z0-9_\-]*\z/ }

  def get_news(site, page_param)
    filter_by.blank? ? news(site, page_param) : news(site, page_param).tagged_with(filter_by.mb_chars.downcase.to_s, any: true)
  end

  def news(site, page_param)
    direction = 'desc'
    site.news_sites.available_fronts.published.joins(news: :site).where(sites: {status: 'active'})
      .order("journal_news_sites.#{order_by} #{direction}").page(page_param).per(quant)
  end
  private :news

  alias_method :_read_more, :read_more
  def read_more
    _read_more.blank? ? false : _read_more.to_i == 1
  end

  alias_method :_tag_as_label, :tag_as_label
  def tag_as_label
    _tag_as_label.blank? ? false : _tag_as_label.to_i == 1
  end

  alias_method :_show_author, :show_author
  def show_author
    _show_author.blank? ? false : _show_author.to_i == 1
  end

  alias_method :_show_date, :show_date
  def show_date
    _show_date.blank? ? false : _show_date.to_i == 1
  end

  def show_tags?
    show_tags.blank? ? false : show_tags.to_i == 1
  end

  def hide_filtered_tags?
    hide_filtered_tags.blank? ? false : hide_filtered_tags.to_i == 1
  end

  alias_method :_image_size, :image_size
  def image_size
    _image_size.blank? ? :m : _image_size
  end

  alias_method :_avatar_width, :avatar_width
  def avatar_width
    _avatar_width.blank? ? '128' : _avatar_width
  end

  alias_method :_quant, :quant
  def quant
    _quant.blank? ? 5 : (_quant.to_i == 0 ? 1 : _quant.to_i)
  end

  alias_method :_new_tab, :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  alias_method :_order_by, :order_by
  def order_by
    _order_by.blank? ? order_types[0].to_s : _order_by
  end

  def date_formats
    [:full, :short]
  end

  def which_date_options
    [:updated_at, :created_at]
  end

  def order_types
    [:position, :created_at, :updated_at]
  end

  def image_sizes
    [:m, :l, :i, :t]
  end
end
