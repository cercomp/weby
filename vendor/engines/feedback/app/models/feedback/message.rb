module Feedback
  class Message < ActiveRecord::Base
    belongs_to :site
    has_and_belongs_to_many :groups

    attr_accessible :email, :message, :name, :subject, :to, :group_ids, :site_id

    validates_presence_of :name, :email, :subject, :message

    validate :at_least_one_group

    def at_least_one_group
      if(Group.where(:site_id => self.site.id).length > 0 and self.groups.length < 1)
        errors.add(:base, :need_at_least_one_group )
      end
    end
  end
end
