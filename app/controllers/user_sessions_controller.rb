# coding: utf-8
class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  before_filter :check_authorization, :except => [:destroy]

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      if current_user and current_user.active? # Verifica se o usuário está ativo  
        flash.now[:success] = t("login_success")
        redirect_back_or_default("#{params[:back_url]}")
      else  
        destroy  
      end  
    else  
      render :action => :new
    end
  end
  
  def destroy
    if current_user 
      if  current_user.active?
        flash.now[:warning] = t('user_inactive')
      else
        flash.now[:success] = t('logout_success')
      end
      current_user_session.destroy
    end
    redirect_back_or_default("#{params[:back_url]}")
  end
end
