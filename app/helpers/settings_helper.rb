module SettingsHelper
  def setting_input_tag(setting)
    name = 'settings[][value]'
    disabled = setting.new_record?
    data = { disabledtext: setting.default_value }
    "<div class=\"input-group setting-input\">".tap do |html|
      if (pattern = Setting::VALUES_SET[setting.name.to_sym])
        case pattern
        when Hash
          if pattern[:select]
            html << select_tag(
              name,
              options_for_select(pattern[:select], setting.value ? setting.value.split(',') : nil),
              { class: 'setting-field select', data: data, disabled: disabled }.merge(pattern[:options]) { |_k, old, new| old.is_a?(String) ? new + ' ' + old : new }
            )
          elsif pattern[:text]
              html << html << text_area_tag(name, setting.value, class: 'setting-field text form-control', data: data, disabled: disabled)
          else
            # TODO another kind of input
          end
        when Array
          html << select_tag(name, options_for_select(pattern, setting.value), class: 'setting-field select form-control', data: data, disabled: disabled)
        when Symbol
          case pattern
          when :numericality
            html << number_field_tag(name, setting.value, class: 'setting-field numeric form-control', data: data, disabled: disabled)
          else
            html << text_field_tag(name, setting.value, class: 'setting-field string form-control', data: data, disabled: disabled)
          end
        else
          html << text_field_tag(name, setting.value, class: 'setting-field string form-control', data: data, disabled: disabled, pattern: pattern)
        end
      else
        html << text_field_tag(name, setting.value, class: 'setting-field string form-control', data: data, disabled: disabled)
      end
      html << content_tag(:span, class: 'input-group-addon') do
        check_box_tag('settings[][enabled]', true, !disabled)
      end
      html << '</div>'
    end.html_safe
  end
end
