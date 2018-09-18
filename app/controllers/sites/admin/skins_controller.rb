class Sites::Admin::SkinsController < ApplicationController
  before_action :require_user
  before_action :check_authorization

  def index
    @themes = Weby::Themes.all
    @components = current_site.active_skin.components.order(position: :asc)
    @placeholders = current_site.theme ? current_site.theme.layout['placeholders'] : []

    @styles = {}
    @styles[:others] = Style.not_followed_by(current_site.id).search(params[:search])
                            .order('sites.name, styles.name')
                            .page(params[:page]).per(params[:per_page])
    @styles[:styles] = current_site.active_skin.styles.includes(:style, :followers, :site) if request.format.html?
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
    theme.populate skin, user: current_user
    flash[:success] = t('successfully_applied_theme')
    record_activity('theme_applied', skin)
    redirect_to site_admin_skins_path
  end

  def preview
    theme = ::Weby::Themes.theme(params[:theme])
    skin = current_site.skins.find_by(theme: theme.name)

    if !skin
      skin = current_site.skins.create(name: theme.name.titleize, theme: theme.name, active: false)
      theme.populate skin, user: current_user
    end

    redirect_to site_path(preview_skin: skin.id)
  end

  def destroy
    skin = current_site.skins.find params[:id]
    skin.components.destroy_all
    skin.styles.destroy_all

    skin.base_theme.populate skin, user: current_user
    flash[:success] = t('.successfully_reseted_theme')
    record_activity('theme_reseted', skin)
    redirect_to site_admin_skins_path
  end
end
