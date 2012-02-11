# coding: utf-8
class PasswordResetsController < ApplicationController
  layout :choose_layout
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user
  skip_before_filter :check_authorization

  def new
    flash.now[:warning] = t("fill_email_form")
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.password_reset!(request.env["SERVER_NAME"])
      flash[:notice] = t("reset_mail")
      redirect_to :back
    else
      flash[:warning] = t("no_mail")
      render :action => :new
    end
  end
  
  def edit
  end  
  
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = t("successfully_updated", :param => t("password"))
      redirect_to @user
    else
      render :action => :edit
    end
  end
  
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = t("missing_account")
      redirect_to root_url
    end
  end
end
