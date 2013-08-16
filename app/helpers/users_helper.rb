module UsersHelper
  # Retorna um hash contendo o site e os papeis que o usuaŕio possui
  # Exemplo: { 'Matematica' => [role1, role2] }
  def sites_with_roles
    sites = {}
    @user.roles.order(:site_id).each do |r|
      role_site_title = r.site.try(:title)
      (sites[role_site_title] ||= []) << r
    end
    sites
  end
  
  # Maneira de realizar um camel case do nome do usuário, assim mesmo que ele escreva
  # o nome em uppercase, será mostrado em camelcase.
  # NOTE procurei no ruby uma função para isso e não achei
  def captalize_name(user)
    [user.first_name, user.last_name].join(' ').split.map{ |word| word.capitalize }.join(' ')
  end

  def has_unread_notifications(text)
    user = User.find(current_user.id)
    unread = user.unread_notifications

    case text
    when "all"
      if current_user.unread_notifications == "$"
        link_to main_app.site_admin_notifications_url(subdomain: current_user.sites.first) do 
          image_tag('envelope.png', style: "width: 14px") 
          end
      else
          link_to main_app.site_admin_notifications_url(subdomain: current_user.sites.first) do
          image_tag('message-new.png', style: "width: 14px") 
          end
      end
    else
      if unread.include?(text)
        image_tag('envelope.png', style: "width: 14px")
      else
        image_tag('message-empty.png', style: "width: 14px")
      end
    end
  end
end
