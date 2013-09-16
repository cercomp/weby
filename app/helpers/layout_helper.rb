module LayoutHelper
  # loads the main stylesheet layout
  # eg: stylesheets/layouts/{name}/main.css 
  def load_layout_stylesheet(layout)
    css_path = "layouts/#{layout}/main.css"
    Weby::Application.assets.find_asset(css_path) ? stylesheet_link_tag(css_path) : ""
  end

  # loads the main javascript layout
  # eg: javascripts/layouts/{name}/main.css 
  def load_layout_javascript(layout)
    js_path = "layouts/#{layout}/main.js"
    Weby::Application.assets.find_asset(js_path) ? javascript_include_tag(js_path) : ""
  end

  # gera um item do menu admin com verificação de classe active
  def menu_item_to title, url
    content_tag :li, link_to(title, url), class: request.path.match(url.to_s) ? 'active' : ''
  end

  # lista com os locales suportados pelo backend
  def admin_locales
    @@admin_locales ||= Locale.where("name in ('pt-BR','en')")
  end

  # render webybar on sites
  def render_webybar
    I18n.with_locale(current_user && current_user.locale ? current_user.locale.name.to_s : current_locale ) do
      render 'layouts/shared/weby_bar'
    end
  end

  private
  def contrast?
    session[:contrast] and session[:contrast] == 'yes' 
  end
end
