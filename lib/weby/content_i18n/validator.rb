module Weby
  module ContentI18n
    class Validator < ActiveModel::Validator
      def validate(record)
        @record = record

        @record.errors.
          add(:base, I18n.t("need_at_least_one_i18n")) unless has_valid_i18ns?

        @record.errors.
          add(:base, I18n.t("cant_have_i18ns_with_same_locale")) if has_duplicated_locales?
      end

      private
      def has_valid_i18ns?
        valid_i18ns.size > 0
      end

      def valid_i18ns
        @record.i18ns.map do |i18n|
          i18n if valid_i18n?(i18n)
        end.compact
      end

      def valid_i18n?(i18n)
        return false if @record.new_record? && i18n.id
        i18n.valid? and not(i18n.marked_for_destruction?)
      end

      def has_duplicated_locales?
        get_locales.length > get_locales.uniq.length
      end

      def get_locales
        [].tap do |locales|
          @record.i18ns.map do |i18n|
            locales << i18n.locale
          end
        end
      end
    end
  end
end
