class ActivityRecord < ActiveRecord::Base
  belongs_to :loggeable, polymorphic: true
  belongs_to :site
  belongs_to :user

  scope :user_or_action_like, ->(text, site_id) {
    joins(:user)
    .where("(LOWER(users.first_name) like :text OR
            LOWER(action) like :text OR
            LOWER(controller) like :text) #{"
              AND activity_records.site_id = :site_id" if site_id.present?
            }", text: "%#{text.try(:downcase)}%", site_id: site_id)
  }

  def loggeable_url_params
    return nil if action == 'destroy'

    prefix = site ? :site_admin : :admin
    controller == 'menu_items' ? [prefix, loggeable.menu, loggeable] : [prefix, loggeable]
  end
end
