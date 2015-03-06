class Sites::Admin::ThemesController < ApplicationController
  def index
    @themes = Weby::Themes.all
  end

  def apply
    theme = ::Weby::Themes.theme(params[:id])
    if current_site.theme
      current_site.theme.update(name: theme.name.titleize, base: theme.name)
    else
      current_site.create_theme(name: theme.name.titleize, base: theme.name)
    end
    theme.populate current_site
    redirect_to site_admin_themes_path
  end

  def preview

  end
end
