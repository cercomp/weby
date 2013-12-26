class ActivityRecord < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :loggeable, polymorphic: true
  
  scope :user_or_action_like, lambda { |text, site_id|
    joins(:user).where("(LOWER(users.first_name) like :text OR LOWER(action) like :text OR LOWER(controller) like :text) #{"AND activity_records.site_id = :site_id" if site_id.present?}",
          { :text => "%#{text.try(:downcase)}%", :site_id => site_id })
  }

  def loggeable_url_params
    return nil if self.action == "destroy"
    self.controller == "menu_items" ?
      [:site_admin, self.loggeable.menu, self.loggeable] : [:site_admin, self.loggeable]
  end

end
