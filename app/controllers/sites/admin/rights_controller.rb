# encoding: UTF-8
class Sites::Admin::RightsController < ApplicationController
  before_filter :require_user
  before_filter :is_admin, :except => [:index, :show]
  before_filter :check_authorization
  respond_to :html, :xml

  def index
    @rights = Right.order("controller,name")
    respond_with(@rights)
  end

  def new
    @right = Right.new
    respond_with(@right)
  end

  def edit
    @right = Right.find(params[:id])
    respond_with(@right)
  end

  def create
    @right = Right.new(params[:right])
    @right.save

    redirect_to @site ? site_admin_right_path(@right) : right_path(@right)
  end

  def update
    @right = Right.find(params[:id])
    @right.update_attributes(params[:right])
    
    redirect_to @site ? site_admin_rights_path : rights_path
  end

  def destroy
    @right = Right.find(params[:id])
    @right.destroy
    respond_with(@right)
  end

  def show
    @right = Right.find(params[:id])
  end
  
end
