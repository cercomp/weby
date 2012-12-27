xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title current_site.name
    xml.description current_site.description
    xml.link published_site_pages_url

    for page in @pages
      xml.item do
        xml.title page.title
        page_image = image_tag(
          full_image_url(page.image),
          {
            width: 200,
            alt: page.image.description,
            title: page.image.description
          }
        ) if page.image
        body = "#{page_image}<br/>#{page.summary}<br/>#{page.text}"
        body += "<br/>#{link_to 'Original', page.url, target: '_blank'}" if page.url.present?
        xml.description body
        #xml.enclosure url: "http://#{request.host}#{":"+request.port.to_s if request.port!=80}#{page.image.archive.url}", length:page.image.archive_file_size, type: page.image.archive_content_type if page.image
        xml.pubDate page.created_at.to_s(:rfc822)
        xml.link site_page_url(page, subdomain: current_site)
        xml.guid site_page_url(page, subdomain: current_site)
      end
    end
  end
end