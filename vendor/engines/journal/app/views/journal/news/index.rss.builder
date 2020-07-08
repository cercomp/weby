xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd" do
  xml.channel do
    xml.title current_site.title
    xml.description current_site.description
    xml.itunes :summary, current_site.description
    xml.link news_index_url
    if current_site.repository.present?
      xml.image do
        xml.url asset_url(current_site.repository.archive.url)
        xml.link main_app.site_url(subdomain: current_site)
      end
      xml.itunes :image, href: asset_url(current_site.repository.archive.url)
    end

    for news_site in @news_sites
      news = news_site.news
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
        body = "#{news_image}<br/>#{render_user_content news.summary}<br/>#{render_user_content news.text}"
        body += "<br/>#{link_to 'Original', news.url, target: '_blank'}" if news.url.present?
        xml.description body
        if @extension.show_author?
          xml.author news.user.fullname
        end
        xml.pubDate news.created_at.to_s(:rfc822)
        xml.link news_url(news, subdomain: current_site)
        xml.guid news_url(news, subdomain: current_site)
        if news.related_files.any?
          file = news.related_files.first
          xml.enclosure url: asset_url(file.archive.url), length: file.archive_file_size, type: file.archive_content_type
          if file.audio?
            #xml.itunes :duration, '10:00' # TODO how to get duration
            xml.itunes :summary, strip_tags(news.summary)
            xml.itunes :keywords, news_site.category_list
            xml.itunes :explicit, 'no'
          end
        end
      end
    end
  end
end