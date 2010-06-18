class RightsController < ApplicationController
  layout :choose_layout
  respond_to :html, :xml

  def index
    @rights = Right.find(:all, :order => "controller,name")
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
    respond_with(@right)
  end

  def update
    @right = Right.find(params[:id])
    @right.update_attributes(params[:right])
    respond_with(@right)
  end

  def destroy
    @right = Right.find(params[:id])
    @right.destroy
    respond_with(@right)
  end
end
