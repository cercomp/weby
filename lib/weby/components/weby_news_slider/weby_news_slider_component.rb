class WebyNewsSliderComponent < Component
  component_settings :news_category

  def pages(site)
    pages = news_category.blank? ? site.pages.limit(5) :
      site.pages.tagged_with(news_category)

    pages.find_all{|i| !i.image.nil? }
  end
end
