class Sites::Admin::RolesController < ApplicationController
  before_action :require_user
  before_action :check_authorization

  respond_to :html
  def index
    @roles = current_site.roles.no_local_admin.order("id")
    @rights = Weby::Rights.permissions(current_site).sort

    if request.put? # && params[:role]
      params[:role] ||= {}
      @roles.each do |role| # params[:role].each do |role, right|
        role.update(permissions: params[:role][role.id.to_s] ? params[:role][role.id.to_s]['permissions'].to_s : '{}')
      end
      flash[:success] = t('successfully_updated')
      redirect_to site_admin_roles_path
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def new
    @role = Role.new
    respond_with(:site_admin, @role)
  end

  def create
    @role = Role.new(role_params)
    @role.permissions ||= '{}'
    @role.save
    record_activity('created_role', @role)

    redirect_to site_admin_roles_path
  end

  def update
    @role = Role.find(params[:id])
    @role.update(role_params)
    record_activity('updated_role', @role)
    redirect_to site_admin_roles_path
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    record_activity('destroyed_role', @role)
    redirect_back(fallback_location: site_admin_roles_path)
  end

  private

  def role_params
    params.require(:role).permit(:site_id, :name)
  end
end
