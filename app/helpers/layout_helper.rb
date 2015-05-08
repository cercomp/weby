module LayoutHelper
  # lista com os locales suportados pelo backend
  def admin_locales
    @@admin_locales ||= Locale.where("name in ('pt-BR','en')")
  end

  # render webybar on sites
  def render_webybar
    I18n.with_locale(current_user && current_user.locale ? current_user.locale.name.to_s : current_locale) do
      render 'layouts/webybar'
    end
  end

  private

  def contrast?
    session[:contrast] && session[:contrast] == 'yes'
  end
end
