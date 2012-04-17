module Weby
  module ContentI18n
    module Model

      attr_reader :model_locale

      def method_missing(method, *args, &block)
        if self.class::I18ns.column_names.include?(method.to_s)
          self.class.send(:define_method, method.to_sym) do

            return nil if self.i18ns.empty?
            case
            when @model_locale.present?
              selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == @model_locale }
            when
              (selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == I18n.locale.to_s }).any?
            when 
              (selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == I18n.default_locale.to_s }).any?
            else
              selected_i18n = self.i18ns
            end
            selected_i18n.first.send(method)
          end
          self.send(method)
        else
          super(method, *args, &block)
        end
      end

      def in(locale = nil)
        @model_locale = locale
        self
      end

    end
  end
end
