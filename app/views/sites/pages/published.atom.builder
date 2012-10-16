atom_feed :language => I18n.locale do |feed|
  feed.title current_site.name
  feed.updated @pages.first.created_at if @pages.any?

  @pages.each do |page|
    feed.entry page, url: site_page_url(page, subdomain: current_site) do |entry|
      entry.title page.title
      entry.summary page.summary, :type => 'html'
      page_image = image_tag(
        full_image_url(page.image),
        {
          width: 200,
          alt: page.image.description,
          title: page.image.description
        }
      ) if page.image
      entry.content "#{page_image}<br/>#{page.summary}<br/>#{page.text}", :type => 'html'

      entry.author do |author|
        author.name page.author.fullname
      end
    end
  end
end