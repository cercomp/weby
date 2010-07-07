class UserSessionsController < ApplicationController
  layout :choose_layout

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
#  skip_before_filter :check_authorization

  def index
    redirect_back_or_default root_path
  end
  def edit
    redirect_back_or_default root_path
  end
  def show
    redirect_back_or_default root_path
  end
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
#      if current_user.status #verifica se o usuário esta ativo  
        flash[:notice] = "Login successful!"
        redirect_back_or_default root_path
#      else  
#        destroy  
#      end  
    else  
      render :action => :new
    end
  end
  
  def destroy
    if !current_user.status
      flash[:warning] = t('user_inactive')
    else
      flash[:notice] = t('logout_success')
    end
    current_user_session.destroy
    redirect_back_or_default login_path
  end
end
