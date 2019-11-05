class SubsiteFrontNewsComponent < Component
  component_settings :quant, :source, :sel_site, :tag_as_label, :hide_author,
                     :label, :link_to_all, :link_to_all_url, :order_by, :label_link

  i18n_settings :label, :link_to_all

  validates :quant, presence: true

  validates :sel_site, presence: true, if: -> { source == 'selected' }

  def get_news(curr_site)
    limit = quant || 5
    direction = 'desc'
    if source == 'selected'
      site = Site.active.find_by(id: sel_site)
      site ? site.news_sites.joins(news: :site).where(sites: {status: 'active'})
               .order("journal_news_sites.#{order_by} #{direction}")
               .available_fronts
               .published
               .limit(limit)
           : Journal::NewsSite.none
    else
      Journal::NewsSite.from_subsites(curr_site)
        .joins(news: :site).where(sites: {status: 'active'})
        .order("journal_news_sites.#{order_by} #{direction}")
        .available_fronts
        .published
        .limit(limit)
    end
  end

  def hide_author?
    hide_author.blank? ? false : hide_author.to_i == 1
  end

  def tag_as_label?
    tag_as_label.blank? ? false : tag_as_label.to_i == 1
  end

  alias_method :_order_by, :order_by
  def order_by
    _order_by.blank? ? order_types[0].to_s : _order_by
  end

  def link_to_all_url_options
    ['news', 'home']
  end

  def source_options
    ['subsites', 'selected']
  end

  def order_types
    [:updated_at, :created_at, :position]
  end
end
