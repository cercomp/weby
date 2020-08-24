# coding: utf-8
class Sites::Admin::UsersController < ApplicationController
  before_action :require_user
  before_action :check_authorization
  serialization_scope :view_context

  respond_to :html, :xml
  helper_method :sort_column

  def change_roles
    params[:role_ids] ||= []
    if params.dig(:user, :id).present?
      require_role = params[:user][:id].is_a? Array # Require role when param user[id] is array - from enrole form
      if !require_role || (require_role && params[:role_ids].present?)
        [params[:user][:id]].flatten.each do |user_id|
          user = User.find(user_id)
          # Clean the roles of an user in a site
          user.roles.delete(user.roles.where(site: current_site))
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

  def create_local_admin_role
    if params.dig(:user, :id).present?
      admin_role = find_or_create_local_admin_role
      params[:user][:id].each do |user_id|
        user = User.find(user_id)
        user.roles << admin_role
      end
    else
      #flash[:notice] = t('.select_user')
    end
    redirect_to action: "manage_roles", anchor: "adms"
  end

  def destroy_local_admin_role
    user_id = params[:id]
    admin_role = current_site.roles.find_by(permissions: "Admin")
    user = User.find(user_id)
    user.role_ids -= [admin_role.id]
    redirect_to action: "manage_roles", anchor: "adms"
  end

  def manage_roles
    # User that have a role and are not ADMIN
    @site_users = User.no_admin.by_site(current_site).includes(:roles).order('users.first_name asc')
    # Users that are site admins
    @site_admins = User.no_admin.local_admin(current_site).order('users.first_name asc')
    # Search for the roles (global/site)
    @roles = current_site.roles.order('id').no_local_admin
    # When it is asked to manage a role
    @user = User.find(params[:user_id]) if params[:user_id]

    #deprecated
    # Select the users that are not ADMIN
    # @users = User.no_admin
    # Users that do not have a role and are not ADMIN
    #@users_unroled = User.actives.no_admin.by_no_site(current_site).order('users.first_name asc')
  end

  def search
    sort = params[:query].present? ? 'users.first_name asc' : 'users.updated_at desc'
    users = User.actives.no_admin
      .by_no_site(current_site) # users that don't have a role on current_site already
      .order(sort)
      .login_or_name_like(params[:query])
      .limit(50)
    msg = users.blank? ? t('.no_user_found') : 'ok'
    render json: users, root: 'users', each_serializer: UserEnroleSerializer, meta: { message: msg }
  end

  def set_preferences
    if params[:contrast].present?
      current_user.preferences['contrast'] = params[:contrast]
      current_user.save
    end
    render json: {ok: true}
  end

  private

  def find_or_create_local_admin_role
    admin_role = current_site.roles.find_by(permissions: 'Admin')
    if admin_role.blank?
      admin_role = current_site.roles.create!(name: 'Administrador', permissions: 'Admin')
    end
    admin_role
  end
end
