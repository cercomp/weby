# encoding: UTF-8
class Admin::RightsController < ApplicationController
  before_filter :require_user
  before_filter :is_admin, :except => [:index, :show]
  before_filter :check_authorization
  respond_to :html, :xml

  def index
    @rights = Right.order("controller,name")
    respond_with(:admin, @rights)
  end

  def new
    @right = Right.new
    respond_with(:admin, @right)
  end

  def edit
    @right = Right.find(params[:id])
    respond_with(:admin, @right)
  end

  def create
    @right = Right.new(params[:right])
    @right.save
    record_activity("created_global_right", @right)

    redirect_to admin_rights_path
  end

  def update
    @right = Right.find(params[:id])
    @right.update_attributes(params[:right])
    record_activity("updated_global_rights", @right)
    
    redirect_to admin_rights_path
  end

  def destroy
    @right = Right.find(params[:id])
    @right.destroy
    record_activity("destroyed_global_rights", @right)
    respond_with(:admin, @right)
  end

  def show
    @right = Right.find(params[:id])
  end
end
