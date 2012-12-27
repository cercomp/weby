module Feedback
  class Group < ActiveRecord::Base
    self.table_name = 'groups'

    belongs_to :site
    has_and_belongs_to_many :messages

    validates_presence_of :name, :emails
  end
end
