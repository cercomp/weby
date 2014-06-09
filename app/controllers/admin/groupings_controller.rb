class Admin::GroupingsController < ApplicationController
  before_filter :require_user
  before_filter :is_admin

  respond_to :html, :xml
  
  def index
    @groupings = Grouping.all
  end

  def new
    @grouping = Grouping.new
    respond_with(:admin, @grouping)
  end

  def create
    @grouping = Grouping.new(params[:grouping])
    @grouping.save
    redirect_to admin_groupings_path
  end

  def edit
    @grouping = Grouping.find params[:id]
    respond_with(:admin, @grouping)
  end

  def update
    @grouping = Grouping.find params[:id]
    @grouping.update(params[:grouping])
    redirect_to admin_groupings_path
  end

  def destroy
    @grouping = Grouping.find params[:id]
    @grouping.destroy
    redirect_to admin_groupings_path
  end
end
