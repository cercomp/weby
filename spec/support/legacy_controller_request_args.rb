# Rails 5 controller specs passed params as a positional hash. Rails 8 uses
# keyword arguments, so adapt this legacy suite at its test boundary.
module LegacyControllerRequestArgs
  REQUEST_METHODS = %i[get post patch put delete head].freeze
  RESERVED_OPTIONS = %i[params session flash headers env xhr as].freeze

  REQUEST_METHODS.each do |http_method|
    define_method(http_method) do |action, *legacy_args, **options, &block|
      positional_params = legacy_args.shift
      positional_session = legacy_args.shift
      positional_flash = legacy_args.shift
      positional_xhr = legacy_args.shift

      keyword_params = options.reject { |key, _| RESERVED_OPTIONS.include?(key) }
      options = options.select { |key, _| RESERVED_OPTIONS.include?(key) }
      params = options.delete(:params) || {}
      params = keyword_params.merge(positional_params || {}).merge(params)
      params[:skin_id] ||= skin.id if respond_to?(:skin) && skin && !params.key?(:skin_id) && !params.key?('skin_id')
      options[:params] = params unless params.empty?
      options[:session] ||= positional_session if positional_session
      options[:flash] ||= positional_flash if positional_flash
      options[:xhr] ||= positional_xhr if positional_xhr

      super(action, **options, &block)
    end
  end
end
