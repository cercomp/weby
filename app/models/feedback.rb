class Feedback < ActiveRecord::Base
  belongs_to :site

  has_and_belongs_to_many :groups

  validates_presence_of :name, :email, :subject, :message

  validate :at_least_one_group

  def at_least_one_group
    if(Group.where(:site_id => self.site.id).length>0 and self.groups.length<1)
      errors.add(:feedback, I18n.t("feedback_need_at_least_one_group"))
    end
  end
end
