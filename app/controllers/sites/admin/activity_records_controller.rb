class Sites::Admin::ActivityRecordsController < ApplicationController
  before_action :require_user
  before_action :check_authorization

  def index
    @activity_records = current_site.activity_records.
                preload(:loggeable).
                includes(:user, :site).
                user_or_action_like(params[:search]).
                by_controller(params[:controller_filter]).
                by_action_name(params[:action_filter]).
                by_user_id(params[:user_id]).
                by_date_range(params[:start_date], params[:end_date]).
                order('activity_records.created_at DESC').
                page(params[:page]).
                per(params[:per_page] || per_page_default)

    load_filters
  end

  def show
    @activity_record = current_site.activity_records.find(params[:id])
  end

  private

  def load_filters
    @controllers_list = [
      [t('.modules.repositories', default: 'Arquivos / Repositório'), 'repositories'],
      [t('.modules.news', default: 'Notícias'), 'news'],
      [t('.modules.pages', default: 'Páginas'), 'pages'],
      [t('.modules.menus', default: 'Menus'), 'menus'],
      [t('.modules.components', default: 'Componentes'), 'components'],
      [t('.modules.skins', default: 'Temas / Skins'), 'skins'],
      [t('.modules.roles', default: 'Papéis'), 'roles'],
      [t('.modules.albums', default: 'Álbuns de Fotos'), 'albums']
    ]
    @actions_list = [
      [t('.actions.create', default: 'Criação / Upload'), 'create'],
      [t('.actions.update', default: 'Atualização / Edição'), 'update'],
      [t('.actions.destroy', default: 'Exclusão / Lixeira'), 'destroy']
    ]
    @users_list = current_site.users.order(:first_name)
  end
end
