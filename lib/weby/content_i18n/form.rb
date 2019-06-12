module Weby
  module ContentI18n
    module Form
      def i18ns_fields_for(locale, *args, &proc)
        fail ArgumentError, 'Missing block' unless block_given?
        @index = @index ? @index + 1 : 0
        object_name = "#{@object_name}[i18ns_attributes][#{@index}]"
        object = @object.i18ns.select { |i18n| i18n.locale_id == locale.id }.first || @object.i18ns.build(locale_id: locale.id)
        @template.concat @template.hidden_field_tag("#{object_name}[id]", object ? object.id : '', class: 'i18n-id')
        @template.concat @template.hidden_field_tag("#{object_name}[locale_id]", locale.id, class: 'loc-id')
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
