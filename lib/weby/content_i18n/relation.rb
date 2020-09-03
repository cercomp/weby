module Weby
  module ContentI18n
    module Relation
      attr_accessor :i18n_fields, :required_i18n_fields
      def self.extended(base)
        # Build i18ns related class
        i18n_class = base.const_set(:I18ns, Class.new(Weby::I18nsTemplate))

        i18n_class.table_name = ("#{base.name.underscore.gsub('/', '_')}_i18ns")
        i18n_class.belongs_to(base.name.underscore.gsub('/', '_').to_sym, touch: true)

        base.class_eval do
          has_many :i18ns,
                   -> { includes(:locale) },
                   class_name: i18n_class.name,
                   foreign_key: "#{base.name.underscore.gsub('/', '_')}_id".to_sym,
                   dependent: :delete_all,
                   inverse_of: base.name.underscore.gsub('/', '_').to_sym

          has_many :locales, through: :i18ns

          validate :validate_i18ns
          validates_associated :i18ns

          # FIXME: Refatorar local das internacionalizações das msg de erro
          def validate_i18ns
            errors.add(:base, I18n.t('need_at_least_one_i18n')) if active_i18ns.none?

            errors.add(:base, I18n.t('cant_have_i18ns_with_same_locale')) if has_duplicated_locales?

            self.class.required_i18n_fields.each do |field|
              i18ns_missing_required_field(field).each do |i18n|
                errors.add(field.to_sym, "(#{I18n.t(i18n.locale.name)}) #{I18n.t('required')}")
              end
            end
          end
          private :validate_i18ns

          def active_i18ns
            i18ns.select { |i18n| !i18n.marked_for_destruction? }
          end
          private :active_i18ns

          def has_duplicated_locales?
            locales = i18ns.map { |i18n| i18n.locale_id }
            locales.length > locales.uniq.length
          end
          private :has_duplicated_locales?

          # Retorna um array com as i18ns que nao possuem o campo requerido
          def i18ns_missing_required_field(field)
            missing = []
            i18ns.each do |i18n|
              missing << i18n unless i18n.send("#{field}?")
            end
            missing
          end
          private :i18ns_missing_required_field

          accepts_nested_attributes_for :i18ns,
                                        allow_destroy: true,
                                        reject_if: proc { |i18n_attrs|
                                          i18n_attrs['id'].blank? &&
                                          i18n_fields.reduce(true) do |mem, element|
                                            mem && i18n_attrs[element].blank?
                                          end
                                        }
        end
      end

      def build_i18n_fields
        class_eval do
          def select_locale(locale = nil)
            case
            when locale
              @selected_i18n = i18ns.detect{ |i18n| i18n.locale.name == locale.to_s }
            when (@selected_i18n = i18ns.detect{ |i18n| i18n.locale.name == I18n.locale.to_s }).present?
            when (@selected_i18n = i18ns.detect{ |i18n| i18n.locale.name == I18n.default_locale.to_s }).present?
            else
              @selected_i18n = i18ns.first
            end
            # se for nil, raise notfound
          end
          private :select_locale

          def which_locale
            return '' if i18ns.empty?
            select_locale unless @selected_i18n
            @selected_i18n.locale
          end

          def other_locales
            locales.reject { |locale| locale.name == which_locale.name }
          end

          def in(locale = nil)
            select_locale(locale)
            self
          end

          # this has no default or fallback
          def i18n_in(locale)
            i18ns.detect{ |i18n| i18n.locale.name == locale.to_s }
          end

          i18n_fields.each do |field|
            send(:define_method, field.to_sym) do
              return '' if i18ns.empty?
              select_locale unless @selected_i18n
              @selected_i18n.send(field.to_sym)
            end
          end
        end
      end
    end
  end
end
