class Sites::Admin::ThemesController < ApplicationController
  before_action :require_user
  before_action :check_authorization

  def index
    @components = current_site.active_skin.components.order(position: :asc)
    @placeholders = current_site.theme ? current_site.theme.layout['placeholders'] : []

    @styles = {}
    @styles[:others] = Style.not_followed_by(current_site.id).search(params[:search])
                            .order('sites.id')
                            .page(params[:page]).per(params[:per_page])
    @styles[:styles] = current_site.active_skin.styles.includes(:style) if request.format.html?
  end
end
