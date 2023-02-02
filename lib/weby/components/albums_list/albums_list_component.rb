class AlbumsListComponent < Component
  component_settings :quant, :tag_as_label, :which_date, :category_filter, :label,
                     :type_filter, :show_tags, :order_by, :html_class

  i18n_settings :label

  validates :quant, presence: true, numericality: { greater_than: 0 }
  validates :html_class, format: { with: /\A[A-Za-z0-9_\-]*\z/ }

  def get_albums(site, page_param)
    filter_by.blank? ? news(site, page_param) : news(site, page_param).tagged_with(filter_by.mb_chars.downcase.to_s, any: true)
  end

  def news(site, page_param)
    direction = 'desc'
    site.news_sites.available_fronts.published.joins(news: :site).where(sites: {status: 'active'})
      .order("journal_news_sites.#{order_by} #{direction}").page(page_param).per(quant)
  end
  private :news

  alias_method :_quant, :quant
  def quant
    _quant.blank? ? 5 : (_quant.to_i == 0 ? 1 : _quant.to_i)
  end

  alias_method :_order_by, :order_by
  def order_by
    _order_by.blank? ? order_types[0].to_s : _order_by
  end

  def order_types
    [:created_at, :updated_at] #:position, 
  end
end
