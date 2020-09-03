# coding: utf-8
class Admin::UsersController < ApplicationController
  include ActsToToggle

  before_action :require_user
  before_action :is_admin, except: [:new, :create]
  respond_to :html, :xml
  helper_method :sort_column
  serialization_scope :view_context

  def change_roles
    params[:role_ids] ||= []
    if params.dig(:user, :id).present?
      require_role = params[:user][:id].is_a? Array # Require role when param user[id] is array - from enrole form
      if !require_role || (require_role && params[:role_ids].present?)
        [params[:user][:id]].flatten.each do |user_id|
          user = User.find(user_id)
          # Clean the user's global roles
          user.roles.delete(user.global_roles)
          user.role_ids += params[:role_ids]
        end
      else
        #flash[:notice] = t('.select_role')
      end
    else
      #flash[:notice] = t('.select_user')
    end
    redirect_to action: "manage_roles"
  end

  def manage_roles
    # Usuários que possuem papel global e não são administradores
    @site_users = User.global_role.no_admin.includes(:roles).order('users.first_name asc')
    # Busca os papéis globais
    @roles = Role.globals
    # Quando a edição dos papeis é solicitada
    @user = User.find(params[:user_id]) if params[:user_id]

    #deprecated
    # Seleciona os todos os usuários que não são administradores
    #@users = User.no_admin
    # Todos os usuários menos os que não são administradores e possuem papeis globais
    # @users_unroled = User.order('users.first_name asc') - (User.admin + User.global_role)
  end

  def search
    sort = params[:query].present? ? 'users.first_name asc' : 'users.updated_at desc'
    users = User.no_admin
      .where.not(id: User.global_role.pluck(:id)) # users that don't have a global role already
      .order(sort)
      .login_or_name_like(params[:query])
      .limit(60)
    msg = users.blank? ? t('.no_user_found') : 'ok'
    render json: users, root: 'users', each_serializer: UserEnroleSerializer, meta: { message: msg }
  end

  def index
    @users = User.login_or_name_like(params[:search]).
      includes(:roles).
      order(sort_column + ' ' + sort_direction).page(params[:page]).
      per((params[:per_page] || per_page_default))

    #if @site
    # @users = @users.by_site(@site.id)
    #end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = t('create_account_successful')
      record_activity('created_user', @user)
      redirect_to admin_user_path(@user)
    else
      flash[:error] = t('problem_create_account')
      render action: :new
    end
  end

  def show
    @user = User.find(params[:id])
    respond_with(:admin, @user)
  end

  def edit
    @user = User.find(params[:id])
    respond_with(:admin, @user)
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    record_activity('updated_user', @user)
    flash[:success] = t(user_params.include?(:email) ? 'updated_account_with_email' : 'updated_account')
    respond_with(:admin, @user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    if @user.errors.full_messages.empty?
      flash[:success] = t('destroyed_param', param: @user.first_name)
      record_activity('destroyed_user', @user)
    else
      flash[:warning] = t('user_cant_be_deleted')
    end
    redirect_to admin_users_path
  end

  private

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def user_params
    params.require(:user).permit(:login, :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :locale_id)
  end

  def toggle_attribute!
    return false if resource.blank? && params[:field].blank?

    if params[:field] == 'confirmed_at'
      resource.update(confirmed_at: (resource.confirmed_at ? nil : Time.current))
    else
      resource.toggle!(params[:field])
    end
  end
end
