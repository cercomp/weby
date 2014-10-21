xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title current_site.name
    xml.description current_site.description
    xml.link news_index_url

    for news in @newslist
      xml.item do
        xml.title news.title
        news_image = image_tag(
          full_image_url(news.image),
          {
            width: 200,
            alt: news.image.description,
            title: news.image.description
          }
        ) if news.image
        body = "#{news_image}<br/>#{news.summary}<br/>#{news.text}"
        body += "<br/>#{link_to 'Original', news.url, target: '_blank'}" if news.url.present?
        xml.description body
        #xml.enclosure url: "http://#{request.host_with_port}#{news.image.archive.url}", news.image.archive_file_size, type: news.image.archive_content_type if news.image
        xml.pubDate news.created_at.to_s(:rfc822)
        xml.link news_url(news, subdomain: current_site)
        xml.guid news_url(news, subdomain: current_site)
      end
    end
  end
end