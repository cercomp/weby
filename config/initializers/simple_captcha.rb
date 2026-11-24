require 'open3'
require 'simple_captcha/utils'
require 'simple_captcha/middleware'
require 'simple_captcha/image'

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

  # Bundled font so ImageMagick never fails on minimal environments without helvetica
  font_path = Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf').to_s
  sc.font = font_path if File.exist?(font_path)
end

module SimpleCaptcha
  module ImageHelpers
    def generate_simple_captcha_image(simple_captcha_key)
      amplitude, frequency = ImageHelpers.distortion(SimpleCaptcha.distortion)
      text = Utils.simple_captcha_value(simple_captcha_key).presence || 'WEBY'

      params = ImageHelpers.image_params(SimpleCaptcha.image_style).dup
      params << "-size #{SimpleCaptcha.image_size}"
      params << "-wave #{amplitude}x#{frequency}"
      params << "-gravity Center"
      params << "-pointsize 22"
      params << "-implode #{ImageHelpers.implode}"

      font = SimpleCaptcha.font.presence
      font ||= Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf').to_s if defined?(Rails) && File.exist?(Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf'))
      params << "-font '#{font}'" if font.present?

      params << "label:#{text}"
      if SimpleCaptcha.noise && SimpleCaptcha.noise > 0
        params << "-evaluate Uniform-noise #{SimpleCaptcha.noise}"
      end
      params << "jpeg:-"

      SimpleCaptcha::Utils.run("convert", params.join(' '))
    end
  end

  module Utils
    # Execute command with binary mode so JPEG stream is not interpreted as UTF-8
    def self.run(cmd, params = "", expected_outcodes = 0)
      command = "#{cmd} #{params}".gsub(/\s+/, " ")

      unless (image_magick_path = SimpleCaptcha.image_magick_path).blank?
        command = File.join(image_magick_path, command)
      end

      output, status = Open3.capture2(command, binmode: true)
      output.force_encoding(Encoding::BINARY)

      unless [expected_outcodes].flatten.include?(status.exitstatus)
        raise ::StandardError, "Error while running #{cmd}: status #{status.exitstatus}"
      end

      output
    end
  end

  class Middleware
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

      font = SimpleCaptcha.font.presence
      font ||= Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf').to_s if defined?(Rails) && File.exist?(Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf'))

      image_data = begin
        generate_simple_captcha_image(code)
      rescue => e
        Rails.logger.error "[SimpleCaptcha] Failed to generate image: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
        # Fallback: basic ImageMagick convert with explicit font
        text = SimpleCaptcha::Utils.simple_captcha_value(code).presence || value.presence || 'WEBY'
        font_opt = font.present? ? "-font '#{font}'" : ""
        cmd = "convert -size 130x42 -background white -fill darkblue #{font_opt} -gravity Center -pointsize 22 label:#{text} jpeg:-"
        out, _ = Open3.capture2(cmd, binmode: true)
        out.force_encoding(Encoding::BINARY)
        out
      end

      image_data.force_encoding(Encoding::BINARY) if image_data.respond_to?(:force_encoding)

      # Ultimate fallback: guaranteed valid 130x42 JPEG image if everything else failed
      if image_data.blank?
        cmd = "convert -size 130x42 xc:white -bordercolor darkblue -border 1 jpeg:-"
        out, _ = Open3.capture2(cmd, binmode: true)
        out.force_encoding(Encoding::BINARY)
        image_data = out
      end

      response_headers = {
        'Content-Type' => 'image/jpeg',
        'Content-Disposition' => "inline; filename='simple_captcha.jpg'",
        'Content-Transfer-Encoding' => 'binary',
        'Cache-Control' => 'no-cache, no-store, must-revalidate, private',
        'Pragma' => 'no-cache',
        'Expires' => '0',
        'Content-Length' => image_data.bytesize.to_s
      }
      [200, response_headers, [image_data]]
    end

    def send_data(response_body, options = {})
      status = options[:status] || 200
      response_body.force_encoding(Encoding::BINARY) if response_body.respond_to?(:force_encoding)
      headers = {
        'Content-Disposition' => "#{options[:disposition]}; filename='#{options[:filename]}'",
        'Content-Type' => options[:type],
        'Content-Transfer-Encoding' => 'binary',
        'Cache-Control' => 'no-cache, no-store, must-revalidate, private',
        'Pragma' => 'no-cache',
        'Expires' => '0',
        'Content-Length' => response_body.bytesize.to_s
      }
      [status, headers, [response_body]]
    end

    def refresh_code(env)
      request = Rack::Request.new(env)

      request.session.delete(:captcha) rescue nil
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
