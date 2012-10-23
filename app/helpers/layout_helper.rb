module LayoutHelper
  def load_layout_stylesheets(theme = 'application')
    raw(%{
      #{stylesheet_link_tag("layouts/#{theme}/main")}
    })
  end

  def menu_item_to title, url
    content_tag :li, link_to(title, url), class: request.path.match(url.match(/\/admin.*/).to_s) ? 'active' : ''
  end

  private
  def contrast?
    session[:contrast] and session[:contrast] == 'yes' 
  end
end
