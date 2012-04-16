module RequiredFields
  def self.extended(base)
    base.has_many :i18ns,
      class_name: "#{base.name}::I18ns",
      include: :locale,
      dependent: :delete_all

    base.has_many :locales, through: :i18ns

    base.validates_with Weby::ContentI18n::Validator

    base.accepts_nested_attributes_for :i18ns,
      allow_destroy: true,
      reject_if: proc { |i18ns|
        i18ns['id'].blank? && 
          base.required_i18n_fields.reduce(true) do |mem, element|
            i18ns[mem].blank? && i18ns[element].blank?
          end
      }
  end

  def required_i18n_fields(*fields)
    @required_i18n_fields = fields
    class << self
      def required_i18n_fields
        @required_i18n_fields
      end
    end
  end
end
