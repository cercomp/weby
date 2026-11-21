# Paperclip's fork and a few older validators still pass the errors.add options
# hash positionally. Rails 8 requires keyword options.
module LegacyActiveModelErrorsOptions
  def add(attribute, type = :invalid, *legacy_options, **options)
    legacy_options.each do |legacy_option|
      options = legacy_option.merge(options) if legacy_option.is_a?(Hash)
    end

    super(attribute, type, **options)
  end
end

ActiveModel::Errors.prepend(LegacyActiveModelErrorsOptions)
