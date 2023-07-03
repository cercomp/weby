module AlbumsHelper

  def publication_status_page(album, options = {})
    ''.tap do |html|
      html << toggle_field(album, 'publish', 'toggle', options)
    end.html_safe
  end

end