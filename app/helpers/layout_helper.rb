module LayoutHelper
  def load_layout_stylesheets(theme = 'application')
    raw(%{
      #{stylesheet_link_tag("layouts/#{theme}/main")}
      #{stylesheet_link_tag("layouts/#{theme}/contrast") if contrast?}
    })
  end

  private
  def contrast?
    session[:contrast] and session[:contrast] == 'yes' 
  end
end
