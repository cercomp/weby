class NewsListComponent < Component
  component_settings :quant, :front, :events, :category

  validates :quant, presence: true

  def pages(site, page)
    category.blank? ?
      site.pages.order('created_at desc').available
    .send(front ? 'front' : 'no_front').send(events ? 'scoped' : 'news')
    .page(page).per(quant) :
      site.pages.order('created_at desc').available.tagged_with(category)
    .send(front ? 'front' : 'no_front').send(events ? 'scoped' : 'news')
    .page(page).per(quant)
  end

  alias :_quant :quant
  def quant
    _quant.blank? ? 5 : _quant.to_i
  end

  alias :_front :front
  def front
    _front.blank? ? false : _front.to_i == 1
  end

  alias :_events :events
  def events
    _events.blank? ? false : _events.to_i == 1
  end

  def default_alias
    self.category
  end
end
