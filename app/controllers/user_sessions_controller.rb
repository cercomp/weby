class UserSessionsController < ApplicationController
  layout :choose_layout
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  before_filter :check_authorization, :except => [:destroy]

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
#      if current_user.status #verifica se o usuário esta ativo  
        flash.now[:notice] = t("login_success")
        redirect_back_or_default("#{params[:back_url]}")
#      else  
#        destroy  
#      end  
    else  
      render :action => :new
    end
  end
  
  def destroy
    if !current_user.status
      flash.now[:warning] = t('user_inactive')
    else
      flash.now[:notice] = t('logout_success')
    end
    current_user_session.destroy
    redirect_back_or_default login_path
  end
end
