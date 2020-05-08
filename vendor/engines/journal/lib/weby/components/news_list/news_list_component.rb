class NewsListComponent < Component
  component_settings :quant, :front, :category, :show_image, :image_size,
                     :show_date, :date_format, :title, :new_tab

  i18n_settings :title

  validates :quant, presence: true, numericality: { greater_than: 0 }

  def news(site, page)
    result = site.news_sites.joins(news: :site).where(sites: {status: 'active'}).order('journal_news_sites.created_at desc').available.published.joins(:news)
    result = result.tagged_with(category.mb_chars.downcase.to_s, any: true) if category.present?
    result = result.no_front unless front
    result.page(page).per(quant)
  end

  alias_method :_quant, :quant
  def quant
    _quant.blank? ? 5 : (_quant.to_i == 0 ? 1 : _quant.to_i)
  end

  alias_method :_front, :front
  def front
    _front.blank? ? false : _front.to_i == 1
  end

  alias_method :_show_image, :show_image
  def show_image
    _show_image.blank? ? false : _show_image.to_i == 1
  end

  alias_method :_image_size, :image_size
  def image_size
    _image_size.blank? ? '48' : _image_size
  end

  alias_method :_show_date, :show_date
  def show_date
    _show_date.blank? ? false : _show_date.to_i == 1
  end

  alias_method :_date_format, :date_format
  def date_format
    _date_format.blank? ? :short : _date_format.to_sym
  end

  alias_method :_category, :category
  def category
    _category.blank? ? nil : _category
  end

  alias_method :_new_tab, :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  def default_alias
    category
  end

  def image_sizes
    %w(32 48 64 128)
  end

  def date_formats
    %w(default mini short medium long event_date_short event_date_full)
  end

  def title_for_link
    if title.present?
      title
    elsif category.present?
      category.camelize
    end
  end
end
