module WebyBarHelper
  def portals
    if current_user
      portals_link
    end
  end

  private
  def portals_link
    if current_user.is_admin
      content_tag :li do
        link_to((t"portal", count: 2), root_path)
      end
    else
      content_tag :li, class: 'sub' do
        link_to((t"portal", count: 2), root_path) + 
          content_tag(:menu, user_sites)
      end
    end
  end

  def user_sites
    "".tap do |sites|
      Site.where(id: current_user.roles.map{|role| role.site_id}).each do |site|
        sites << (content_tag :li, link_to(site.name, site_path(site))) 
      end
    end.html_safe
  end
end
