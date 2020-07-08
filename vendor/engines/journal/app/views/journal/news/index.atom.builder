atom_feed :language => I18n.locale do |feed|
  feed.title current_site.name
  feed.updated @news_sites.first.created_at if @news_sites.any?

  @news_sites.each do |news_site|
    news = news_site.news
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
      body = "#{news_image}<br/>#{render_user_content news.summary}<br/>#{render_user_content news.text}"
      body += "<br/>#{link_to 'Original', news.url, target: '_blank'}" if news.url.present?
      entry.content body, :type => 'html'
      if @extension.show_author?
        entry.author do |author|
          author.name news.user.fullname
        end
      end
    end
  end
end