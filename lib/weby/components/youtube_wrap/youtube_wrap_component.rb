class YoutubeWrapComponent < Component
  component_settings :url, :html_class, :width, :height, :start, :controls, :privacy

  def show_controls?
    controls.blank? ? true : controls.to_i == 1
  end

  def is_privacy?
    privacy.blank? ? false : privacy.to_i == 1
  end

  def embed_host
    if is_privacy?
      "https://www.youtube-nocookie.com/embed/"
    else
      "https://www.youtube.com/embed/"
    end
  end

  def parse_start
    start.to_s
  end

  def shortcode
    url.match(/v=(.*)/)[1]
  end

  def embed_url
    params = {}
    params[:controls] = '0' if !show_controls?
    params[:start] = parse_start if start.present?
    query = params.to_a.map{|a| a.join('=') }.join('&')
    query = "?#{query}" if query.present?

    "#{embed_host}#{shortcode}#{query}"
  end

  validates :url, presence: true
  validates :html_class, format: { with: /\A[A-Za-z0-9_\-]*\z/ }

end
