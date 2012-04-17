module Weby
  module ContentI18n
    module RequiredFields
      def required_i18n_fields(*fields)
        @required_i18n_fields = fields

        self.class_eval do
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

        class << self
          def required_i18n_fields
            @required_i18n_fields
          end
        end
      end

    end
  end
end
