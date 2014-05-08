class Admin::RolesController < ApplicationController
  include RoleCommon
  before_filter :require_user
  before_filter :is_admin

  respond_to :html, :xml 
  def new
    @role = Role.new
    respond_with(:admin, @role)
  end

  def create
    @role = Role.new(params[:role])
    @role.save
    record_activity("created_global_role", @role)
    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def update
    @role = Role.find(params[:id])
    @role.update_attributes(params[:role])
    record_activity("updated_global_role", @role)
    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    record_activity("destroyed_global_role", @role)
    redirect_to :back
  end
end
