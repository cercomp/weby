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
    case start.to_s
    when /^\d+$/
      start.to_s
    when /^\d+:\d+$/
      parts = start.to_s.split(':')
      (parts[0].to_i * 60) + parts[1].to_i
    end
  end

  def shortcode
    uri = URI.parse(url.to_s.strip)
    params = {}

    if uri.query.present?
      parts = uri.query.split('&')
      params = parts.map{|p| p.match('=') ? p.split('=') : nil }.compact.to_h
    end

    if params['v'].present?
      return params['v']
    end

    if uri.host == 'youtu.be'
      return uri.path[1..-1]
    end

    if uri.path.match(/\/embed\//)
      return uri.path.gsub('/embed/', '')
    end
  end

  #https://youtu.be/gaDHG7RySfg
  #https://www.youtube.com/watch?v=xRzeOzsZCX0&list=PL8BTpGAaXEViUgAX3ZqqZMuE1zN8YcOR9&index=5&t=0s
  #https://www.youtube.com/embed/N9a2FRZqEuU

  def embed_url
    params = {}
    params[:controls] = '0' if !show_controls?
    params[:start] = parse_start if start.present?
    query = params.to_a.map{|a| a.join('=') }.join('&')
    query = "?#{query}" if query.present?

    "#{embed_host}#{shortcode}#{query}"
  end

  validates :url, presence: true
  validates :html_class, format: { with: /\A[A-Za-z0-9_\-\s]*\z/ }

end
