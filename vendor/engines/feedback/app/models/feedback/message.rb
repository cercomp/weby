module Feedback
  class Message < Feedback::ApplicationRecord
    belongs_to :site

    has_and_belongs_to_many :groups, join_table: :feedback_messages_groups

    validates :name, :email, :subject, :message, presence: true

    validate :at_least_one_group

    scope :name_or_subject_like, ->(text) {
      where('LOWER(name) like :text OR LOWER(subject) like :text',
            text: "#{text.try(:downcase)}%")
    }

    def at_least_one_group
      if Group.where(site_id: site.id).length > 0 && groups.length < 1
        errors.add(:base, :need_at_least_one_group)
      end
    end

    def self.import(attrs, _options = {})
      return attrs.each { |attr| import attr } if attrs.is_a? Array

      attrs = attrs.dup
      attrs = attrs['message'] if attrs.key?('message') && !attrs.key?('name')

      attrs.except!('id', '@type', 'created_at', 'updated_at', 'site_id', 'type')

      self.create!(attrs)
    end
  end
end
