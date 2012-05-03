class Sites::RolesController < ApplicationController
  layout :choose_layout
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
    @rights = Right.order("controller,name")

    if params[:role] && request.put?
      params[:role].each do |role, right|
        Role.find(role).update_attributes(right)
      end
      redirect_to @site ? site_roles_path : roles_path
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def show
    @role = Role.new
    @roles = Role.order("id")
    @rights = Right.order("id")
    respond_with(@roles)
  end

  def new
    @role = Role.new
    respond_with(@role)
  end

  def create
    @role = Role.new(params[:role])
    @role.save

    redirect_to @site ? site_roles_path : roles_path
  end

  def update
    @role = Role.find(params[:id])
    @role.update_attributes(params[:role])
    redirect_to @site ? site_roles_path : roles_path
  end

  def destroy
    @roles = Role.find(params[:id])
    @roles.destroy
    redirect_to :back
  end
end
