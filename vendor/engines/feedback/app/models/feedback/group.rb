module Feedback
  class Group < Feedback::ApplicationRecord
    belongs_to :site

    has_and_belongs_to_many :messages, join_table: :feedback_messages_groups

    validates :name, :emails, presence: true
  end
end
