class ActivityRecord < ApplicationRecord
  belongs_to :loggeable, polymorphic: true
  belongs_to :site, optional: true
  belongs_to :user

  scope :user_or_action_like, ->(text) {
    if text.present?
      joins(:user)
      .where("(LOWER(users.first_name) like :text OR
            LOWER(action) like :text OR
            LOWER(controller) like :text)", text: "%#{text.try(:downcase)}%")
    end
  }

  def is_linkable?
    (action != "destroy" || note.to_s.match(/reseted/)) && loggeable_id.present? && loggeable_type.present?
  end

end
