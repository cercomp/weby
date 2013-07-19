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
        link_to((t"portal", count: 2), main_app.root_url(subdomain: nil))
      end
    else
      content_tag :li, class: 'sub' do
        link_to((t"portal", count: 2), main_app.root_url(subdomain: nil)) +
          content_tag(:menu, user_sites)
      end
    end
  end
end
