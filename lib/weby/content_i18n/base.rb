require 'weby/content_i18n/validator'
require 'weby/content_i18n/model'
require 'weby/content_i18n/form'

module Weby
  module ContentI18n
    module Base
      include Model
      def self.included(base)
        base.validates_with Weby::ContentI18n::Validator
      end
    end
  end
end
