# coding: utf-8
class Admin::UsersController < ApplicationController
  include ActsToToggle

  before_action :require_user
  before_action :is_admin, except: [:new, :create]
  respond_to :html, :xml
  helper_method :sort_column

  def change_roles
    params[:role_ids] ||= []
    user_ids = []
    user_ids.push(params[:user][:id]).flatten!

    user_ids.each do |user_id|
      user = User.find(user_id)
      #  Clean all user's roles in the site
      user.role_ids.each do |role_id|
        if @site and @site.roles.map{|r| r.id }.index(role_id)
          user.role_ids -= [role_id]
        end
      end

      # If it is an global role
      unless @site
        user.roles.where(site_id: nil).each{|r| user.role_ids -= [r.id] }
      end
      # NOTE Maybe it is better to use (user.role_ids += params[:role_ids]).uniq
      user.role_ids += params[:role_ids]
    end
    redirect_to action: 'manage_roles'
  end

  def manage_roles
    # Select the users that are not ADMIN
    #@users = User.no_admin
    # User that have a role and are not ADMIN
    @site_users = User.no_admin.by_site(@site).order('users.first_name asc')
    # Users that do not have a role and are not ADMIN
    @users_unroled = User.actives.no_admin.by_no_site(@site).order('users.first_name asc')
    # Search for the roles (global/site)
    @roles = @site.roles.order("id")
    # When it is asked to manage a role
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def index
    @users = User.login_or_name_like(params[:search]).
      order(sort_column + " " + sort_direction).page(params[:page]).
      per((params[:per_page] || per_page_default ))

    if @site
      @users = @users.by_site(@site.id)
    end

    @roles = Role.select('id, name, theme').
      group("id, name, theme").order("id")
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = t("create_account_successful")
      record_activity("created_user", @user)
      redirect_to admin_user_path(@user)
    else
      flash[:error] = t("problem_create_account")
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
    record_activity("updated_user", @user)
    flash[:success] = t("updated_account")
    respond_with(:admin, @user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    if @user.errors.full_messages.empty?
      flash[:success] = t("destroyed_param", param: @user.first_name)
      record_activity("destroyed_user", @user)
    else
      flash[:warning] = t("user_cant_be_deleted")
    end
    redirect_to admin_users_path
  end

  private

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def user_params
    params[:user].slice(:login, :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :locale_id)
  end

  def toggle_attribute!
    return false if resource.blank? && params[:field].blank?

    if params[:field] == 'confirmed_at'
      resource.update(confirmed_at: (resource.confirmed_at ? nil : Time.now))
    else
      resource.toggle!(params[:field])
    end
  end
end
