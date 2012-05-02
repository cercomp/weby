xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title current_site.name
    xml.description current_site.description
    xml.link site_pages_url(current_site)

    for page in @pages
      xml.item do
        xml.title page.title
        xml.description page.summary
        xml.pubDate page.created_at.to_s(:rfc822)
        xml.link site_page_url(current_site,page)
        xml.guid site_page_url(current_site,page)
      end
    end
  end
end