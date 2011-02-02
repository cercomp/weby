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
    params[:type] ||= 'image'

    @repositories = Repository.search(@site.id, params[:search], params[:page], params[:type])
    if @repositories.empty?
      flash.now[:warning] = (t"none_param", :param => t("picture"))
    end
    respond_with do |format|
      format.js #{ render :partial => 'form' }
      format.html
    end
  end

  def update
  end

  def destroy
  end
end
