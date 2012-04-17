require 'weby/content_i18n/form'

module Weby
  module ContentI18n
    def self.included(base)
      base.extend I18nInterface
    end

    module I18nRelation
      attr_accessor :i18n_fields, :required_i18n_fields

      def self.extended(base)
        base.class_eval do
          attr_reader :wanted_locale
          def in(locale = nil)
            @wanted_locale = locale 
            self
          end

          has_many :i18ns,
            class_name: "#{name}::I18ns",
            include: :locale,
            dependent: :delete_all

          has_many :locales, through: :i18ns

          validates_with Weby::ContentI18n::Validator

          accepts_nested_attributes_for :i18ns,
            allow_destroy: true,
            reject_if: proc { |i18ns|
              i18ns['id'].blank? && 
                required_i18n_fields.reduce(true) do |mem, element|
                  i18ns[mem].blank? && i18ns[element].blank?
                end
            }
        end
      end

      def build_i18n_fields
        i18n_fields.each do |field|
          self.class_eval do 
            self.send(:define_method, field.to_sym) do
              return nil if self.i18ns.empty?

              case
              when @wanted_locale.present?
                selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == @wanted_locale }
              when
                (selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == I18n.locale.to_s }).any?
              when 
                (selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == I18n.default_locale.to_s }).any?
              else
                selected_i18n = self.i18ns
              end
              selected_i18n.first.send(field.to_sym)
            end
          end
        end
      end
    end

    module I18nInterface
      def weby_content_i18n(fields, options = {})
        self.extend I18nRelation
        self.i18n_fields = [fields].flatten
        self.required_i18n_fields = [options[:required]].flatten
        build_i18n_fields
      end
    end
  end
end

ActiveRecord::Base.send(:include, Weby::ContentI18n)
