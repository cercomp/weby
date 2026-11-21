# frozen_string_literal: true

# Compatibility patch for Rails 8 ActiveRecord strict loading.
# When ActiveRecord models are deserialized from cache (e.g. Redis / Memcached / Marshal)
# that were saved prior to Rails 8 or without @strict_loading_mode, owner.strict_loading_mode
# returns nil. This causes association loading (such as set_strict_loading) to fail with:
# "ArgumentError: The :mode option must be one of [:all, :n_plus_one_only] but nil was provided."

module ActiveRecordStrictLoadingCompatibility
  def strict_loading_mode
    super || (self.class.respond_to?(:strict_loading_mode) && self.class.strict_loading_mode) || :all
  end

  def strict_loading!(value = true, mode: :all)
    mode ||= :all
    super(value, mode: mode)
  end
end

ActiveSupport.on_load(:active_record) do
  prepend(ActiveRecordStrictLoadingCompatibility)
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.prepend(ActiveRecordStrictLoadingCompatibility)
end
