class SessionController < ApplicationController
  before_filter :require_no_user, except: :logout
  before_filter :require_user, only: :logout
  before_filter :load_user_using_perishable_token, only: :reset_password

  def login
    @session = UserSession.new
  end

  def create_session
    request.session_options[:domain] = ".#{current_domain}"
    @session = UserSession.new(params[:user_session])
    if @session.save
      if current_user and current_user.active?
        redirect_back_or_default "#{params[:back_url]}"
      else
        logout  
      end  
    else
      render action: :login
    end
  end

  def logout
    if current_user
      request.session_options[:domain] = ".#{current_domain}"
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

  def signup
    @user = User.new
  end

  def create_user
    @user = User.new(params[:user])
    if @user.save
      @user.send_activation_instructions!(request.env["SERVER_NAME"])
      flash[:success] = t("create_account_successful")
      redirect_to login_path
    else
      flash[:error] = t("problem_create_account")
      render :action => :signup
    end
  end

  def activate_user
    @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Exception)
    raise Exception if @user.active?
    if @user.activate!
      UserSession.create(@user, false)
      @user.send_activation_confirmation!(request.env["SERVER_NAME"])
      redirect_to root_url(subdomain: nil)
    else
      render :action => :login
    end
  end
  
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id], 1.week)
    unless @user
      flash[:error] = t("missing_account")
      redirect_to login_url(subdomain: nil, protocol: login_protocol)
    end
  end

  def current_domain
    request.host.split('.').last(request.session_options[:tld_length].to_i).join('.')
  end
end
