atom_feed :language => I18n.locale do |feed|
  feed.title current_site.name
  feed.updated @events.first.created_at if @events.any?

  @events.each do |event|
    feed.entry event, url: event_url(event, subdomain: current_site) do |entry|
      entry.title event.name
      entry.summary event.information, :type => 'html'
      event_image = image_tag(
        full_image_url(event.image),
        {
          width: 200,
          alt: event.image.description,
          title: event.image.description
        }
      ) if event.image
      body = "#{event_image}<br/>#{event.place}<br/>#{event.information}"
      body += "<br/>#{link_to 'Original', event.url, target: '_blank'}" if event.url.present?
      entry.content body, :type => 'html'

      entry.author do |author|
        author.name event.user.fullname
      end
    end
  end
end