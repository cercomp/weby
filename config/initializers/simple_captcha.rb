SimpleCaptcha.setup do |sc|
  # default: 100x28
  sc.image_size = '130x42'

  # default: 5
  sc.length = 5

  # default: simply_blue
  sc.image_style = 'simply_blue'

  # default: low
  sc.distortion = 'low'

  # default: medium
  sc.implode = 'none'
end

Rails.application.config.to_prepare do
  SimpleCaptcha::Middleware.class_eval do
    protected

    def make_image(env, headers = {}, status = 404)
      request = Rack::Request.new(env)
      code = request.params['code'].to_s.strip

      # Generate a fallback code if parameter was empty
      if code.blank?
        code = SimpleCaptcha::Utils.generate_key(Time.now.to_f.to_s, 'fallback')
      end

      # Auto-heal: if captcha code is missing from DB or expired, generate a fresh value
      # so users never get a broken image (404) or failed validation
      value = SimpleCaptcha::Utils.simple_captcha_value(code)
      if value.blank?
        value = generate_simple_captcha_data(nil)
        data = SimpleCaptcha::SimpleCaptchaData.get_data(code)
        data.value = value
        data.save
      end

      image_data = generate_simple_captcha_image(code)
      response_headers = {
        'Content-Type' => 'image/jpeg',
        'Content-Disposition' => "inline; filename='simple_captcha.jpg'",
        'Content-Transfer-Encoding' => 'binary',
        'Cache-Control' => 'no-cache, no-store, must-revalidate, private',
        'Pragma' => 'no-cache',
        'Expires' => '0'
      }
      [200, response_headers, [image_data]]
    rescue => e
      Rails.logger.error "[SimpleCaptcha] Failed to generate image: #{e.message}"
      [status, headers, []]
    end

    def send_data(response_body, options = {})
      status = options[:status] || 200
      headers = {
        'Content-Disposition' => "#{options[:disposition]}; filename='#{options[:filename]}'",
        'Content-Type' => options[:type],
        'Content-Transfer-Encoding' => 'binary',
        'Cache-Control' => 'no-cache, no-store, must-revalidate, private',
        'Pragma' => 'no-cache',
        'Expires' => '0'
      }
      [status, headers, [response_body]]
    end

    def refresh_code(env)
      request = Rack::Request.new(env)

      request.session.delete :captcha rescue nil
      key = simple_captcha_key(nil, request)
      options = {}
      options[:field_value] = set_simple_captcha_data(key, options)
      url = simple_captcha_image_url(key, options)

      status = 200
      id = request.params['id']
      captcha_hidden_field_id = simple_captch_hidden_field_id(id)
      format = SimpleCaptcha.refresh_format.to_sym
      formats = SimpleCaptcha::Middleware::REFRESH_FORMATS
      raise ::ArgumentError, "Format adapter '#{format}' is not available" unless format.in?(formats)

      body = formats[format] % {id: id, url: url, captcha_hidden_field_id: captcha_hidden_field_id, key: key}

      headers = {
        'Content-Type' => 'text/javascript; charset=utf-8',
        'Content-Disposition' => "inline; filename='captcha.js'",
        'Content-Length' => body.bytesize.to_s,
        'Cache-Control' => 'no-cache, no-store, must-revalidate, private',
        'Pragma' => 'no-cache',
        'Expires' => '0'
      }.merge(SimpleCaptcha.extra_response_headers)
      [status, headers, [body]]
    end
  end
end
