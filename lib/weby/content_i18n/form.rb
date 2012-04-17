module Weby
  module ContentI18n
    module Form
      def i18ns_fields_for(locale, *args, &proc)
        raise ArgumentError, "Missing block" unless block_given?
        @index = @index ? @index + 1 : 0
        object_name = "#{@object_name}[i18ns_attributes][#{@index}]"
        object = @object.i18ns.find_by_locale_id(locale.id) || @object.i18ns.build(locale_id: locale.id)
        @template.concat @template.hidden_field_tag("#{object_name}[id]", object ? object.id : "")
        @template.concat @template.hidden_field_tag("#{object_name}[locale_id]", locale.id)
        if @template.respond_to? :simple_fields_for
          @template.simple_fields_for(object_name, object, *args, &proc)
        else
          @template.fields_for(object_name, object, *args, &proc)
        end
      end
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, Weby::ContentI18n::Form)
