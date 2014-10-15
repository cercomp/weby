# coding: utf-8
class Sites::Admin::UsersController < ApplicationController
  before_action :require_user
  before_action :check_authorization

  respond_to :html, :xml
  helper_method :sort_column

  def change_roles
    params[:role_ids] ||= []
    user_ids = []
    user_ids.push(params[:user][:id]).flatten!

    user_ids.each do |user_id|
      user = User.find(user_id)
      # Clean the roles of an user in a site
      user.role_ids.each do |role_id|
        if @site and @site.roles.map { |r| r.id }.index(role_id)
          user.role_ids -= [role_id]
        end
      end

      # If it is a global role, clean the global roles
      unless @site
        user.roles.where(site_id: nil).each { |r| user.role_ids -= [r.id] }
      end
      # NOTE maybe it is better to use (user.role_ids += params[:role_ids]).uniq
      # that way we remove the each above
      user.role_ids += params[:role_ids]
    end
    redirect_to action: "manage_roles"
  end

  def create_local_admin_role
    user_ids = []
    user_ids.push(params[:user][:id]).flatten!
    admin_role = current_site.roles.find_by(permissions: "Admin")
    if admin_role.nil?
      role = Role.new
      role.name = 'Administrador'
      role.permissions = 'Admin'
      role.site_id = current_site.id
      role.save
      admin_role = current_site.roles.find_by(permissions: "Admin")
    end
    user_ids.each do |user_id|
      user = User.find(user_id)
      user.roles << admin_role 
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
    # Select the users that are not ADMIN
    # @users = User.no_admin
    # User that have a role and are not ADMIN
    @site_users = User.no_admin.by_site(@site).order('users.first_name asc')
    # Users that do not have a role and are not ADMIN
    @users_unroled = User.actives.no_admin.by_no_site(@site).order('users.first_name asc')
    # Users that are site admins
    @site_admins = User.no_admin.local_admin(@site).order('users.first_name asc')
    # Search for the roles (global/site)
    @roles = @site.roles.order('id').no_local_admin
    # When it is asked to manage a role
    @user = User.find(params[:user_id]) if params[:user_id]
  end
end
