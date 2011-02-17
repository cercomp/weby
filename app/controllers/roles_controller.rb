class RolesController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml
  def index
    @roles = Role.order("id").all
    @rights = Right.order("controller,name").all

    if params[:role] && request.put?
      params[:role].each do |role, right|
        Role.find(role).update_attributes(right)
      end
    end
    respond_with(@roles)
  end

  def edit
    @role = Role.find(params[:id])
    files = []
    for file in Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*")]
      files << file.split("/")[-1].split(".")[0]
    end
    @themes = files
  end

  def show
    @role = Role.new
    @roles = Role.order("id").all
    @rights = Right.order("id").all
    respond_with(@roles)
  end

  def new
    @role = Role.new
    respond_with(@role)
  end

  def create
    @role = Role.new(params[:role])
    @role.save
    redirect_to(roles_path)
  end

  def update
    @role = Role.find(params[:id])
    @role.update_attributes(params[:role])
    redirect_to(roles_path)
  end

  def destroy
    @roles = Role.find(params[:id])
    @roles.destroy
    redirect_to :back
  end
end
