require 'weby/content_i18n/form'
require 'weby/content_i18n/model'
require 'weby/content_i18n/required_fields'
require 'weby/content_i18n/validator'

module Weby
  module ContentI18n
    module Base
      include Model
      def self.included(base)
        base.extend RequiredFields
      end
    end
  end
end
