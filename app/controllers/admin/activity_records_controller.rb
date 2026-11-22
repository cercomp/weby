class Admin::ActivityRecordsController < ApplicationController
  before_action :require_user
  before_action :is_admin
  respond_to :html, :js

  def index
    @activity_records = ActivityRecord.
                preload(:loggeable).
                includes(:user, :site).
                user_or_action_like(params[:search]).
                by_controller(params[:controller_filter]).
                by_action_name(params[:action_filter]).
                by_user_id(params[:user_id]).
                by_date_range(params[:start_date], params[:end_date]).
                order('activity_records.created_at DESC')

    if params[:site_id].present?
      @activity_records = @activity_records.where(site_id: params[:site_id])
    end

    @activity_records = @activity_records.page(params[:page]).per(params[:per_page] || per_page_default)
    load_filters
  end

  def show
    @activity_record = ActivityRecord.find(params[:id])
  end

  def destroy
    @activity_record = ActivityRecord.find(params[:id])
    @activity_record.destroy
    flash[:success] = t('destroyed_record')

    redirect_to admin_activity_records_path
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
      [t('.modules.users', default: 'Usuários'), 'users'],
      [t('.modules.roles', default: 'Papéis'), 'roles'],
      [t('.modules.sites', default: 'Sites'), 'sites']
    ]
    @actions_list = [
      [t('.actions.create', default: 'Criação / Upload'), 'create'],
      [t('.actions.update', default: 'Atualização / Edição'), 'update'],
      [t('.actions.destroy', default: 'Exclusão / Lixeira'), 'destroy']
    ]
    @users_list = User.order(:first_name)
  end
end
