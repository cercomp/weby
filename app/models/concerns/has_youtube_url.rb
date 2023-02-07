module HasYoutubeUrl
  extend ActiveSupport::Concern

  included do
    #
  end

  def embed_host
    if respond_to?(:is_privacy?) && is_privacy?
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
    _url = case
    when respond_to?(:url)
      url
    when respond_to?(:video_url)
      video_url
    end
    uri = URI.parse(_url.to_s.strip)
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
    params[:controls] = '0' if respond_to?(:show_controls?) && !show_controls?
    params[:start] = parse_start if respond_to?(:start) && start.present?
    query = params.to_a.map{|a| a.join('=') }.join('&')
    query = "?#{query}" if query.present?

    "#{embed_host}#{shortcode}#{query}"
  end

end
