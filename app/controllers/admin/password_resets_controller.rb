# coding: utf-8
class Admin::PasswordResetsController < ApplicationController
  layout 'user_sessions'
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user
  skip_before_filter :check_authorization

  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.password_reset!(request.env["SERVER_NAME"])
      flash[:success] = t("reset_mail")
      render :action => :new
    else
      flash[:error] = t("no_mail")
      render :action => :new
    end
  end
  
  def edit
  end  
  
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:success] = t("successfully_updated", :param => t("password"))
      redirect_to @user
    else
      render :action => :edit
    end
  end
  
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id], 1.week)
    unless @user
      flash[:error] = t("missing_account")
      redirect_to root_url
    end
  end
end
