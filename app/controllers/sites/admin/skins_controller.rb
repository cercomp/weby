class Sites::Admin::SkinsController < ApplicationController
  def index
    @themes = Weby::Themes.all
  end

  def create
    theme = ::Weby::Themes.theme(params[:theme])
    skin = current_site.skins.find_by(theme: theme.name)

    current_site.skins.update_all active: false
    if skin
      skin.update active: true
    else
      skin = current_site.skins.create(name: theme.name.titleize, theme: theme.name, active: true)
    end
    theme.populate skin
    flash[:success] = t('successfully_applied_theme')
    redirect_to site_admin_skins_path
  end

  def preview
    theme = ::Weby::Themes.theme(params[:theme])
    skin = current_site.skins.find_by(theme: theme.name)

    if !skin
      skin = current_site.skins.create(name: theme.name.titleize, theme: theme.name, active: false)
      theme.populate skin
    end

    redirect_to site_path(preview_skin: skin.id)
  end

  def show
    @skin = current_site.skins.find params[:id]
  end
end
