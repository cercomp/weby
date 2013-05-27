class Admin::RolesController < ApplicationController
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
    @roles = @site ? @site.roles.order("id") : Role.where(:site_id => nil)
    @rights = Weby::Rights.permissions.sort

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

  def new
    @role = Role.new
    respond_with(:admin, @role)
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
    @role = Role.find(params[:id])
    @role.destroy
    redirect_to :back
  end
end
