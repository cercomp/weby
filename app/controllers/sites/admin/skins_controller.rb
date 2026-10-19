class Sites::Admin::SkinsController < ApplicationController
  before_action :require_user
  before_action :check_authorization, except: [:index, :show]
  before_action :load_skin, only: [:show, :destroy, :apply, :preview, :edit, :update, :add_custom_color, :remove_custom_color]

  def index
    skins = current_site.skins.order(:name)
    if skins.empty?
      redirect_to new_site_admin_skin_path
    else
      active_skin = current_site.active_skin
      redirect_to site_admin_skin_path(active_skin.persisted? ? active_skin : skins.first)
    end
  end

  def show
    @active_skin = current_site.active_skin
    @skins = current_site.skins.order(:name).reject{|sk| sk.theme == @active_skin.theme }

    @components = @skin.components.includes(:skin).order(position: :asc)
    @placeholders = @skin.base_theme&.layout['placeholders']&.to_a

    @styles = {}
    @styles[:others] = Style.not_followed_by(@skin).search(params[:search])
                            .joins(:site).where(sites: {status: 'active'})
                            .order('sites.name, styles.name')
                            .page(params[:page]).per(params[:per_page])
    @styles[:styles] = @skin.styles.includes(:style, :followers, :site) if request.format.html? #.where(sites: {status: 'active'})
  end

  def new
    installed_themes = current_site.skins.pluck(:theme)
    @themes = Weby::Themes.all.reject{|th| installed_themes.include?(th.name) }.sort_by(&:name)
    if !current_user.is_admin
      @themes.reject!{|th| th.is_private }
    end
  end

  def create
    theme = ::Weby::Themes.theme(params[:theme])
    skin = current_site.skins.find_by(theme: theme.name)
    if theme.is_private && !current_user.is_admin
      flash[:error] = t('only_admin')
      redirect_to site_admin_skins_path
      return
    end
    if skin.blank?
      skin = current_site.skins.create(name: theme.name.titleize, theme: theme.name)
      record_activity('theme_installed', skin)
    else
      # should NOT call this action for themes already installed
      flash[:error] = t('theme_already_installed')
      redirect_to site_admin_skin_path(skin)
      return
    end

    alert = t('successfully_installed_theme')
    if params[:apply].to_s == 'true'
      alert = apply_skin(skin)
    end

    theme.populate skin, user: current_user
    flash[:success] = alert
    redirect_to site_admin_skin_path(skin)
  end

  def edit
    @theme = @skin.base_theme
  end

  def update
    theme = @skin.base_theme
    theme.variables.each do |name, config|
      selected_value = params[name]
      @skin.set_variable(name, selected_value)
      if config['type'] == 'color'
        if params["#{name}_custom"].present?
          custom_data = JSON.parse(params["#{name}_custom"])
          custom_data.each do |key, value|
            @skin.add_custom_color(name, value['main'], key)
          end
        end
      end
    end

    @skin.save!

    flash[:success] = t('.successfully_updated_theme')
    redirect_to site_admin_skin_path(@skin)
  end

  def apply
    flash[:success] = apply_skin(@skin)
    redirect_to site_admin_skin_path(@skin)
  end

  def preview
    redirect_to site_path(preview_skin: @skin.id)
  end

  def destroy
    @skin.components.destroy_all
    @skin.styles.destroy_all

    @skin.base_theme.populate @skin, user: current_user
    flash[:success] = t('.successfully_reseted_theme')
    record_activity('theme_reseted', @skin)
    redirect_to site_admin_skin_path(@skin)
  end

  def add_custom_color
    return redirect_to :back, flash: { error: t('only_admin') } unless current_user.is_admin?

    color_name = params[:color_name]
    color_value = params[:color_value]
    variable_name = params[:variable_name]

    if color_name.present? && color_value.present? && variable_name.present?
      custom_colors = @skin.get_custom_colors(variable_name)
      custom_colors[color_name] = {
        'main' => color_value,
        'sub' => adjust_color_brightness(color_value, -20),
        'group' => 'custom'
      }
      @skin.set_custom_colors(variable_name, custom_colors)
      @skin.save!

      flash[:success] = t('.custom_color_added')
      record_activity('added_custom_color', @skin)
    else
      flash[:error] = t('.invalid_color_data')
    end

    redirect_to edit_site_admin_skin_path(@skin)
  end

  def remove_custom_color
    return redirect_to :back, flash: { error: t('only_admin') } unless current_user.is_admin?

    color_name = params[:color_name]
    variable_name = params[:variable_name]

    if color_name.present? && variable_name.present?
      custom_colors = @skin.get_custom_colors(variable_name)
      custom_colors.delete(color_name)
      @skin.set_custom_colors(variable_name, custom_colors)
      @skin.save!

      flash[:success] = t('.custom_color_removed')
      record_activity('removed_custom_color', @skin)
    else
      flash[:error] = t('.invalid_color_data')
    end

    redirect_to edit_site_admin_skin_path(@skin)
  end

  private

  def adjust_color_brightness(hex_color, percent)
    # Remove o # se presente
    hex = hex_color.gsub('#', '')

    # Converte para RGB
    rgb = hex.scan(/../).map { |color| color.to_i(16) }

    # Ajusta o brilho
    rgb = rgb.map do |color|
      new_color = color + (color * percent / 100.0)
      [[new_color, 255].min, 0].max.round
    end

    # Converte de volta para hex
    "##{rgb.map { |color| color.to_s(16).rjust(2, '0') }.join}"
  end

  def apply_skin skin
    current_site.skins.update_all active: false
    skin.update active: true
    record_activity('theme_applied', skin)
    t('successfully_applied_theme')
  end

  def add_custom_color
    return redirect_to edit_site_admin_skin_path(current_site, @skin), alert: 'Acesso negado' unless current_user.is_admin?

    variable_name = params[:variable_name]
    color_value = params[:color_value]

    if variable_name.present? && color_value.present?
      @skin.add_custom_color(variable_name, color_value)
      redirect_to edit_site_admin_skin_path(current_site, @skin), notice: 'Cor personalizada adicionada com sucesso'
    else
      redirect_to edit_site_admin_skin_path(current_site, @skin), alert: 'Cor é obrigatória'
    end
  end

  def remove_custom_color
    return redirect_to edit_site_admin_skin_path(current_site, @skin), alert: 'Acesso negado' unless current_user.is_admin?

    variable_name = params[:variable_name]
    color_name = params[:color_name]

    if variable_name.present? && color_name.present?
      @skin.remove_custom_color(variable_name, color_name)
      redirect_to edit_site_admin_skin_path(current_site, @skin), notice: 'Cor personalizada removida com sucesso'
    else
      redirect_to edit_site_admin_skin_path(current_site, @skin), alert: 'Parâmetros inválidos'
    end
  end

  def load_skin
    @skin = current_site.skins.find(params[:id])
  end
end
