class Sites::Admin::RolesController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  before_filter :load_themes, :only => [:new, :edit]

  def load_themes
    @themes = []
    for file in Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*")]
      @themes << file.split("/")[-1].split(".")[0]
    end
  end

  respond_to :html, :xml
  def index
    @roles = params[:deleted] == 'true' ? Role.unscoped.where(deleted: true, site_id: current_site.id).order("id") : current_site.roles.order("id")
    @rights = Weby::Rights.permissions.sort
    render "trash" if params[:deleted] == 'true'
    
    if request.put? #&& params[:role]
      params[:role] ||= {}
      @roles.each do |role| #params[:role].each do |role, right|
        role.update_attributes(permissions: params[:role][role.id.to_s] ? params[:role][role.id.to_s]['permissions'].to_s : "{}")
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

    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def update
    @role = Role.find(params[:id])
    @role.update_attributes(params[:role])
    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def destroy
    @role = Role.unscoped.find(params[:id])
    @role.destroy
    redirect_to :back
  end

  def remove
    @role = Role.unscoped.find(params[:id])
    if @role.update_attributes(deleted: true)
      RolesUser.delete_all("role_id = #{@role.id}")
    end

    redirect_to @site ? site_admin_roles_path : admin_roles_path
  end

  def recover
    @role = current_site.roles.unscoped.find(params[:id])
    @role.update_attributes(deleted: false)

    redirect_to  site_admin_roles_path(deleted: true)
  end

end
