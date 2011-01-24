class AdminController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js

  def index
  end

  def show
  end

  def edit
    @repositories = Repository.search(params[:search], params[:page])
  end

  def update
  end

  def destroy
  end
end
