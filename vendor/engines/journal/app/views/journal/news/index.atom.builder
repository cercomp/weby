atom_feed :language => I18n.locale do |feed|
  feed.title current_site.name
  feed.updated @newslist.first.created_at if @newslist.any?

  @newslist.each do |news|
    feed.entry news, url: news_url(news, subdomain: current_site) do |entry|
      entry.title news.title
      entry.summary news.summary, :type => 'html'
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
      entry.content body, :type => 'html'

      entry.author do |author|
        author.name news.user.fullname
      end
    end
  end
end