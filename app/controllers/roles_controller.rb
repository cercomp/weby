class RolesController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml

  def index
    @roles = Role.find(:all, :order => "id")
    @rights = Right.find(:all, :order => "controller,name")

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
    @roles = Role.find(:all, :order => "id")
    @rights = Right.find(:all, :order => "id")
    respond_with(@roles)
  end

  def new
    respond_with(@roles = Role.new)
  end

  def create
    @roles = Role.new(params[:role])
    @roles.save
    respond_with(@roles)
  end

  def update
    @role = Role.find(params[:id])
    @role.update_attributes(params[:role])
    respond_with(@role)
  end

  def destroy
    @roles = Role.find(params[:id])
    @roles.destroy
    respond_with(@roles)
  end
end
