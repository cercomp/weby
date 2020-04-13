require 'weby/content_i18n/relation'
require 'weby/content_i18n/form'
require 'weby/content_i18n/i18ns_template'

module Weby
  module ContentI18n
    def weby_content_i18n(*data)
      fields = data.select { |item| item.is_a?(Symbol) }
      options = data.select { |item| item.is_a?(Hash) }[0] || {}

      extend Relation
      self.i18n_fields = [fields].flatten
      self.required_i18n_fields = [options[:required]].flatten
      build_i18n_fields
    end
  end
end

::ActiveRecord::Base.extend(Weby::ContentI18n)
