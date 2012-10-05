module LayoutHelper
  def load_layout_stylesheets(theme = 'application')
    raw(%{
      #{stylesheet_link_tag("layouts/#{theme}/main")}
    })
  end

  private
  def contrast?
    session[:contrast] and session[:contrast] == 'yes' 
  end
end
