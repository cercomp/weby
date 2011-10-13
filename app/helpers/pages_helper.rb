module PagesHelper
  # TODO verificação temporária para migração deve ser apagada após a migração
  def recreate_thumbs!(page)
    if File.file?(page.repository.archive.path) and 
      not File.file?(page.repository.archive.path(:little))
      page.repository.archive.reprocess!
    end
  end

  def link_to_cover_image(page)
    link_to image_tag("#{page.repository.archive.url(:mini)}",
                      :alt => page.repository.description),
                      site_page_path(@site, page, :type => params[:type]),
                      :title => page.repository.description
  end  

  def thumbnail_on_show
    raw image_tag(page_image, align: "right", size: page_image_size)
  end

  # Retorna um link externo quando existente ou um link interno da página. 
  # Recebe uma página e o site.
  def link_on_title(site, page)
      if page.url.nil?
        site_page_path(@site, page)
      else
        page.url
      end
  end

  private
  def page_image
    page_image? ? 
      @page.repository.archive.url(:little) :
      @page.repository.archive.url(:original)
  end

  def page_image_size
    '128x128' unless page_image?
  end

  def page_image?
    @page.repository.image?
  end

end
