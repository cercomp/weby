class SimpleCaptchaController < ApplicationController
  skip_before_action :set_global_vars, :set_contrast, :set_locale, :set_view_types, :maintenance_mode, raise: false
  skip_before_action :verify_authenticity_token, raise: false
  after_action :weby_clear, :count_view, if: -> { false }

  include SimpleCaptcha::ViewHelper
  include SimpleCaptcha::ImageHelpers

  def show
    if params[:code].present?
      code = params[:code].to_s.strip
      value = SimpleCaptcha::Utils.simple_captcha_value(code)
      if value.blank?
        value = generate_simple_captcha_data(nil)
        data = SimpleCaptcha::SimpleCaptchaData.get_data(code)
        data.value = value
        data.save
      end

      font = SimpleCaptcha.font.presence
      font ||= Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf').to_s if File.exist?(Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf'))

      image_data = begin
        generate_simple_captcha_image(code)
      rescue => e
        Rails.logger.error "[SimpleCaptchaController] standard image generation failed: #{e.message}"
        font_opt = font.present? ? "-font '#{font}'" : ""
        cmd = "convert -size 130x42 -background white -fill darkblue #{font_opt} -gravity Center -pointsize 22 label:#{value} jpeg:-"
        out, _ = Open3.capture2(cmd, binmode: true)
        out.force_encoding(Encoding::BINARY)
        out
      end

      image_data.force_encoding(Encoding::BINARY) if image_data.respond_to?(:force_encoding)

      if image_data.blank?
        cmd = "convert -size 130x42 xc:white -bordercolor darkblue -border 1 jpeg:-"
        out, _ = Open3.capture2(cmd, binmode: true)
        out.force_encoding(Encoding::BINARY)
        image_data = out
      end

      response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate, private'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = '0'

      send_data image_data, type: 'image/jpeg', disposition: 'inline', filename: 'simple_captcha.jpg'
    elsif params[:id].present?
      request.session.delete(:captcha) rescue nil
      key = simple_captcha_key(nil, request)
      options = {}
      options[:field_value] = set_simple_captcha_data(key, options)
      url = simple_captcha_image_url(key, options)

      id = params[:id]
      captcha_hidden_field_id = simple_captch_hidden_field_id(id)
      body = %Q{
        $("#%s").attr('src', '%s');
        $("#%s").attr('value', '%s');
      } % [id, url, captcha_hidden_field_id, key]

      response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate, private'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = '0'
      render js: body
    else
      key = SimpleCaptcha::Utils.generate_key(Time.now.to_f.to_s, 'fallback')
      value = generate_simple_captcha_data(nil)
      data = SimpleCaptcha::SimpleCaptchaData.get_data(key)
      data.value = value
      data.save

      font = SimpleCaptcha.font.presence
      font ||= Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf').to_s if File.exist?(Rails.root.join('app/assets/fonts/myriad-regular/MYRIADPROREGULAR.ttf'))

      image_data = begin
        generate_simple_captcha_image(key)
      rescue => e
        font_opt = font.present? ? "-font '#{font}'" : ""
        cmd = "convert -size 130x42 -background white -fill darkblue #{font_opt} -gravity Center -pointsize 22 label:#{value} jpeg:-"
        out, _ = Open3.capture2(cmd, binmode: true)
        out.force_encoding(Encoding::BINARY)
        out
      end

      image_data.force_encoding(Encoding::BINARY) if image_data.respond_to?(:force_encoding)

      if image_data.blank?
        cmd = "convert -size 130x42 xc:white -bordercolor darkblue -border 1 jpeg:-"
        out, _ = Open3.capture2(cmd, binmode: true)
        out.force_encoding(Encoding::BINARY)
        image_data = out
      end

      response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate, private'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = '0'

      send_data image_data, type: 'image/jpeg', disposition: 'inline', filename: 'simple_captcha.jpg'
    end
  end
end
