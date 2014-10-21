xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title current_site.name
    xml.description current_site.description
    xml.link events_url

    for event in @events
      xml.item do
        xml.title event.name
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
        xml.description body
        #xml.enclosure url: "http://#{request.host_with_port}#{event.image.archive.url}", event.image.archive_file_size, type: event.image.archive_content_type if event.image
        xml.pubDate event.created_at.to_s(:rfc822)
        xml.link event_url(event, subdomain: current_site)
        xml.guid event_url(event, subdomain: current_site)
      end
    end
  end
end