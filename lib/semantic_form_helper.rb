module SemanticFormHelper
      
  def wrapping(type, field_name, label, field, options = {})
    help = %Q{<span class="help">#{options[:help]}</span>} if options[:help]
    to_return = ""
    to_return << %Q{<div class="#{type}-field #{options[:class]}">}
    to_return << %Q{<label for="#{field_name}">#{label}#{help}</label>} unless ["radio","check", "submit"].include?(type)
    to_return << %Q{<div class="input">}
    to_return << field
    to_return << %Q{<label for="#{field_name}">#{label}</label>} if ["radio","check"].include?(type)    
    to_return << %Q{</div></div>}
    to_return.html_safe
  end

  def semantic_group(type, field_name, label, fields, will, options = {})
    help = %Q{<span class="help">#{options[:help]}</span>} if options[:help]
    to_return = ""
    to_return << %Q{<div class="#{type}-fields #{options[:class]}">}
    to_return << %Q{<label for="#{field_name}">#{label}#{help}</label>}
#    to_return << %Q{<div id="#{options[:more]}">} if "#{options[:more]}"
    to_return << %Q{<div class="input">}
    to_return << fields.join
    to_return << %Q{#{will}}
#    to_return << %Q{</div>} if "#{options[:more]}"
    to_return << %Q{</div></div>}
    to_return.html_safe
  end

  def boolean_field_wrapper(input, name, value, text, help = nil)
    field = ""
    field << %Q{#{input} #{text}\n}
    field << %Q{<div class="help">#{help}</div>} if help
    field.html_safe
  end

  def insert_img(input, image, alt, title)
    field = ""
    field << %Q{<img src="#{image}" width="70", height="70" alt="#{alt}" title="#{title}"> </img>}
    field.html_safe
  end

  def check_box_tag_group(name, values, will, obj, options = {})
    selections = []
    values.each do |item|
      if item.is_a?(Hash)
        value = item[:value]
        text = item[:label]
        help = item.delete(:help)
      else
        value = item
        text = item
      end
      box = check_box_tag(name, value, obj.include?(item[:obj]))
      selections << boolean_field_wrapper(box, name, value, text)
    end
    label = options[:label]
    semantic_group("check-box", name, label, selections, will, options) 
  end      
end
