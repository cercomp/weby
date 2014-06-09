class Sites::Admin::RolesController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
 
  respond_to :html
  def index
    @roles = @site ? @site.roles.order("id") : Role.where(site_id: nil).order("id")
    @rights = Weby::Rights.permissions.sort
    
    if request.put? # && params[:role]
      params[:role] ||= {}
      @roles.each do |role| # params[:role].each do |role, right|
        role.update(permissions: params[:role][role.id.to_s] ? params[:role][role.id.to_s]['permissions'].to_s : "{}")
      end
      flash[:success] = t("successfully_updated")
      redirect_to @site ? site_admin_roles_path : admin_roles_path
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def show
    @role = Role.new
    @roles = Role.order("id")
    @rights = Right.order("id")
    respond_with(:site_admin, @roles)
  end

  def new
    @role = Role.new
    respond_with(:site_admin, @role)
  end

  def create
    @role = Role.new(params[:role])
    @role.save
    record_activity("created_role", @role)

    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def update
    @role = Role.find(params[:id])
    @role.update(params[:role])
    record_activity("updated_role", @role)
    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    record_activity("destroyed_role", @role)
    redirect_to :back
  end
end
