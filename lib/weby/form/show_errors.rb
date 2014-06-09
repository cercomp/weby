module Weby
  module Form
    module ShowErrors
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      def show_errors
        if @object.errors.any?
          @template.content_tag :div, id: 'error_explanation', class: 'alert alert-error' do
            "#{error_title} #{content_tag :ul, error_list}".html_safe
          end
        end
      end

      def error_title
        content_tag :b, %(
          #{pluralize(@object.errors.count, '')}
          #{I18n.t('prohibited_being_saved', count: @object.errors.count)}
        )
      end
      private :error_title

      def error_list
        ''.tap do |li|
          @object.errors.full_messages.each do |error|
            li << content_tag(:li, error)
          end
        end.html_safe
      end
      private :error_list
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, Weby::Form::ShowErrors)
