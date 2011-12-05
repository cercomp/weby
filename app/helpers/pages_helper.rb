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

  def international_fields(locale, form)
    form.fields_for :page_i18ns do |i18nbuilder| 
      render('page_i18ns/form', f: i18nbuilder, locale: locale)
    end 
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
