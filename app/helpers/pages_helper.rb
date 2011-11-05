module PagesHelper

  def thumbnail_on_show
    raw image_tag(page_image(format), align: "right", size: page_image_size)
  end

  # Retorna um link externo quando existente ou um link interno da página. 
  # Recebe uma página e o site.
  def link_on_title(site, page)
      if page.url.nil? or page.url.empty?
        site_page_path(site, page)
      else
        page.url
      end
  end
  
  def link_to_page_type(type)
    link_to t("#{type.to_s.try(:downcase)}#{'.one'}"),
      new_site_page_path(:type => type.to_s),
      :update => "div_link",
      :remote => true
  end

  def links_to_page_type(type = "News")
    links_hash = {
      'News' => "<span>#{t 'news.one' }</span> #{ link_to_page_type :Event }",
      'Event' => "#{ link_to_page_type :News} <span>#{t 'event.one' }</span>"
    }

    raw links_hash[type]
  end
  
  private
  def page_image(format)
    page_image? ? 
      @page.repository.archive.url(format) :
      @page.repository.archive.url(:original)
  end

  def page_image_size
    '128x128' unless page_image?
  end

  def page_image?
    @page.repository.image?
  end

end
