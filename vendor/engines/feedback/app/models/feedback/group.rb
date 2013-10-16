module Feedback
  class Group < ActiveRecord::Base
    belongs_to :site
    has_and_belongs_to_many :messages, :join_table => :feedback_messages_groups

    validates_presence_of :name, :emails

    scope :not_deleted, lambda { where(deleted: false) }
    scope :deleted, lambda { where(deleted: true) }     

  end
end
