# frozen_string_literal: true

# Ruby 3 keyword arguments compatibility for Kaminari tags.
# In Ruby 2.7, passing a hash positionally as the second argument was automatically
# converted into keyword arguments. Ruby 3 requires explicit kwargs or splatting.
# This patch ensures backward compatibility if legacy templates or helpers invoke
# Kaminari::Helpers::Tag.new(template, options_hash).

require 'kaminari'

module KaminariLegacyTagOptions
  def initialize(template, *legacy_args, **options)
    if legacy_args.first.is_a?(Hash)
      options = legacy_args.first.merge(options)
    end
    super(template, **options)
  end
end

Kaminari::Helpers::Tag.prepend(KaminariLegacyTagOptions)
