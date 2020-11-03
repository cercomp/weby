module Feedback
  class Group < Feedback::ApplicationRecord
    belongs_to :site

    has_and_belongs_to_many :messages, join_table: :feedback_messages_groups

    validates :name, :emails, presence: true
    validate :validate_position

    def self.update_positions(site, groups=[])
      groups.each_with_index do |group_id, idx|
        site.groups.where(id: group_id).update_all(position: idx)
      end
    end

    def emails_array
      emails.split(/[\s|,]/).select(&:present?)
    end

    private

    def validate_position
      self.position = last_position + 1 if self.position.nil?
      #self.position = 0 if self.position.nil?
    end

    def last_position
      site.groups.maximum(:position).to_i
    end
  end
end
