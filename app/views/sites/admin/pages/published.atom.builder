atom_feed :language => I18n.locale do |feed|
  feed.title current_site.name
  feed.updated @pages.first.created_at

  @pages.each do |page|
    feed.entry page, url: site_page_url(current_site, page) do |entry|
      entry.title page.title
      entry.summary page.summary
      entry.content page.text, :type => 'html'

      entry.author do |author|
        author.name page.author.fullname
      end
    end
  end
end