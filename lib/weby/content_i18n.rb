require 'weby/content_i18n/form'
require 'weby/content_i18n/i18ns'

module Weby
  module ContentI18n
    def self.included(base)
      base.extend I18nInterface
    end

    module I18nRelation
      attr_accessor :i18n_fields, :required_i18n_fields
      def self.extended(base)
        # Build i18ns related class
        i18n_class = base.const_set(:I18ns, Class.new(Weby::I18ns))

        i18n_class.table_name = ("#{base.name.underscore.gsub('/', '_')}_i18ns")
        i18n_class.belongs_to(base.name.underscore.gsub('/', '_'))

        base.class_eval do
          has_many :i18ns,
            class_name: i18n_class.name,
            include: :locale,
            dependent: :delete_all

          has_many :locales, through: :i18ns

          validate :validate_i18ns

          # FIXME: Refatorar local das internacionalizações das msg de erro
          def validate_i18ns
            self.errors.add(:base, I18n.t('need_at_least_one_i18n')) if active_i18ns.none? 

            self.errors.add(:base, I18n.t('cant_have_i18ns_with_same_locale')) if has_duplicated_locales?

            self.class.required_i18n_fields.each do |field|
              self.errors.add(field.to_sym, I18n.t("required")) if !has_valid?(field)
            end
          end
          private :validate_i18ns

          def active_i18ns
            self.i18ns.select { |i18n| !i18n.marked_for_destruction? } 
          end
          private :active_i18ns

          def has_duplicated_locales?
            locales = self.i18ns.map {|i18n| i18n.locale_id}
            locales.length > locales.uniq.length 
          end
          private :has_duplicated_locales?

          def has_valid?(field)
            self.i18ns.each do |i18n|
              return false unless i18n.send("#{field}?")
            end
            true
          end
          private :has_valid?

          accepts_nested_attributes_for :i18ns,
            allow_destroy: true,
            reject_if: proc { |i18ns|
              i18ns['id'].blank? &&
                required_i18n_fields.reduce(true) do |mem, element|
                  mem && i18ns[element].blank?
                end
            }
        end
      end

      def build_i18n_fields
        self.class_eval do
          def select_locale(locale=nil)
            case
            when locale
              @selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == locale.to_s }.first
            when !(@selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == I18n.locale.to_s }.first).blank?
            when !(@selected_i18n = self.i18ns.select{|i18n| i18n.locale.name == I18n.default_locale.to_s }.first).blank?
            else
              @selected_i18n = self.i18ns.first
            end
            #se for nil, raise notfound

          end
          private :select_locale

          def which_locale
            return '' if self.i18ns.empty?
            select_locale unless @selected_i18n
            @selected_i18n.locale
          end

          def other_locales
            self.locales.reject{|locale| locale.name == self.which_locale.name }
          end

          def in(locale = nil)
            select_locale(locale)
            self
          end

          i18n_fields.each do |field|
            self.send(:define_method, field.to_sym) do
              return '' if self.i18ns.empty?
              select_locale unless @selected_i18n
              @selected_i18n.send(field.to_sym)
            end
          end
        end
      end
    end

    module I18nInterface
      def weby_content_i18n(*data)
        fields = data.select { |item| item.is_a?(Symbol) }
        options = data.select { |item| item.is_a?(Hash) }[0] || {}

        self.extend I18nRelation
        self.i18n_fields = [fields].flatten
        self.required_i18n_fields = [options[:required]].flatten
        build_i18n_fields
      end
    end
  end
end

ActiveRecord::Base.send(:include, Weby::ContentI18n)
