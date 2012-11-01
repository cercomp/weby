module LayoutHelper
  def load_layout_stylesheets(theme = 'application')
    raw(%{
      #{stylesheet_link_tag("layouts/#{theme}/main")}
    })
  end

  # gera um item do menu admin com verificação de classe active
  def menu_item_to title, url
    content_tag :li, link_to(title, url), class: request.path.match(url.match(/\/admin.*/).to_s) ? 'active' : ''
  end

  #lista com os locales suportados pelo backend
  def admin_locales
    @@admin_locales ||= Locale.where("name in ('pt-BR','en')")
  end

  #render webybar on frontends
  def render_webybar
    I18n.with_locale(current_user && current_user.locale ? current_user.locale.name.to_s : current_locale ) do
      render 'layouts/shared/webybar'
    end
  end

  private
  def contrast?
    session[:contrast] and session[:contrast] == 'yes' 
  end
end
