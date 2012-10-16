class SessionController < ApplicationController
  before_filter :require_no_user, except: :destroy
  before_filter :require_user, only: :destroy
  before_filter :load_user_using_perishable_token, only: :reset_password

  def new
    @session = UserSession.new
  end

  def create
    @session = UserSession.new(params[:user_session])
    if @session.save
      if current_user and current_user.active?
        redirect_back_or_default "#{params[:back_url]}"
      else
        destroy  
      end  
    else
      render action: :new
    end
  end

  def destroy
    if current_user 
      flash.now[:success] = t("logout_success")
      current_user_session.destroy
    end
    redirect_to ("#{params[:back_url]}")
  end

  def forgot_password
  end
  
  def password_sent
    @user = User.find_by_email(params[:email])
    if @user
      @user.password_reset!(request.env["SERVER_NAME"])
    else
      flash[:error] = t("no_mail")
      render action: :forgot_password
    end
  end

  def reset_password
  end

  def update_password
    @user = User.find(params[:user][:id])
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:success] = t("successfully_updated_password")
      redirect_to admin_user_path(@user)
    else
      render action: :reset_password
    end
  end
  
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id], 1.week)
    unless @user
      flash[:error] = t("missing_account")
      redirect_to login_url 
    end
  end
end
