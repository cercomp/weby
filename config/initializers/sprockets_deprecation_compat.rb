# frozen_string_literal: true

# Rails 8 made ActiveSupport::Deprecation.warn private on the class.
# sprockets-rails (and other gems) still call ActiveSupport::Deprecation.warn(...)
# directly when assets are not found in the asset pipeline.
if defined?(ActiveSupport::Deprecation)
  ActiveSupport::Deprecation.singleton_class.class_eval do
    public :warn if private_instance_methods.include?(:warn)
  end
end
