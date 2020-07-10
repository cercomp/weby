module UsersHelper
  # Returns an hash that contains the sites and the roles that an user owns
  # Eg: { 'Math' => [role1, role2] }
  def sites_with_roles
    sites = {}
    @user.roles.order(:site_id).each do |r|
      role_site_title = r.site.try(:title)
      (sites[role_site_title] ||= []) << r
    end
    sites
  end

  def notifications_icon
    user = User.find(current_user.id)
    unread = user.unread_notifications_array
    if unread.empty?
      link_to main_app.notifications_url(subdomain: current_site), class: 'label label-default', title: t('notifications.index.notifications') do
        icon('bell', glyph: true)
      end
    else
      link_to main_app.notifications_url(subdomain: current_site) do
        content_tag(:span, class: 'label label-warning', title: t('notifications.index.notifications')) do
          icon('bell', glyph: true, text: unread.size)
        end
      end
    end
  end
end
