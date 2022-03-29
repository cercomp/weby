# coding: utf-8
class Admin::AppsController < ApplicationController
  before_action :require_user
  before_action :is_admin
  respond_to :html
  helper_method :sort_column
  def index
    @apps = App.name_like(params[:search]).
      order(sort_column + ' ' + sort_direction).page(params[:page]).
      per((params[:per_page] || per_page_default))
  end

  def new
    @app = App.new
  end

  def create
    @app = App.new(app_params)
    if @app.save
      flash[:success] = t('create_app_successful')
      record_activity('created_app', @app)
      redirect_to admin_app_path(@app)
    else
      flash[:error] = t('problem_create_app')
      render action: :new
    end
  end

  def show
    @app = App.find(params[:id])
    respond_with(:admin, @app)
  end

  def edit
    @app = App.find(params[:id])
    respond_with(:admin, @app)
  end

  def update
    @app = App.find(params[:id])
    @app.update(app_params)
    record_activity('updated_app', @app)
    flash[:success] = t('updated_app')
    respond_with(:admin, @app)
  end

  def destroy
    @app = App.find(params[:id])
    @app.destroy
    if @app.errors.full_messages.empty?
      flash[:success] = t('destroyed_param', param: @app.name)
      record_activity('destroyed_app', @app)
    else
      flash[:warning] = t('app_cant_be_deleted')
    end
    redirect_to admin_apps_path
  end

  private

  def sort_column
    App.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

  def app_params
    params.require(:app).permit(:name, :code)
  end
end
