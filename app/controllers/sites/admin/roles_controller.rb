class Sites::Admin::RolesController < ApplicationController
  before_action :require_user
  before_action :check_authorization

  respond_to :html
  def index
    @roles = @site.roles.order("id").no_local_admin
    @rights = Weby::Rights.permissions.sort

    if request.put? # && params[:role]
      params[:role] ||= {}
      @roles.each do |role| # params[:role].each do |role, right|
        role.update(permissions: params[:role][role.id.to_s] ? params[:role][role.id.to_s]['permissions'].to_s : '{}')
      end
      flash[:success] = t('successfully_updated')
      redirect_to @site ? site_admin_roles_path : admin_roles_path
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def show
    @role = Role.new
    @roles = Role.order('id')
    @rights = Right.order('id')
    respond_with(:site_admin, @roles)
  end

  def new
    @role = Role.new
    respond_with(:site_admin, @role)
  end

  def create
    @role = Role.new(role_params)
    @role.save
    record_activity('created_role', @role)

    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def update
    @role = Role.find(params[:id])
    @role.update(role_params)
    record_activity('updated_role', @role)
    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    record_activity('destroyed_role', @role)
    redirect_to :back
  end

  private

  def role_params
    params.require(:role).permit(:site_id, :name)
  end
end
