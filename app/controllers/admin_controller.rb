class AdminController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization

  def index
  end

  def show
  end

  def update
  end

  def destroy
  end
end
