class SessionController < ApplicationController
  before_filter :require_no_user, except: :logout
  before_filter :require_user, only: :logout
  before_filter :load_user_using_perishable_token, only: :reset_password
  before_filter :set_domain

  def login
    @session = UserSession.new
  end

  def create_session
    @session = UserSession.new(params[:user_session])
    if @session.save
      if current_user and current_user.active?
        redirect_back_or_default "#{params[:back_url]}"
      else
        logout  
      end  
    else
      if @session.attempted_record && !@session.attempted_record.active? and !@session.invalid_password?
        render action: :resend_activation
      else
        render action: :login
      end
    end
  end

  def logout
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
      if @user.active?
        redirect_to admin_user_path(@user)
      else
        @session = UserSession.new
        render :action => :login
      end
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
      redirect_to login_url(subdomain: nil, protocol: login_protocol)
    else
      flash[:error] = t("problem_create_account")
      render :action => :signup
    end
  end

  def activate_user
    @user = User.find_using_perishable_token(params[:activation_code], 1.week)
    if not @user
      flash[:error] = t("invalid_activation_token")
    else
      if @user.active?
        flash[:error] = t("user_already_active")
      else
        if @user.activate!
          UserSession.create(@user, false)
          @user.send_activation_confirmation!(request.env["SERVER_NAME"])
          redirect_to root_url(subdomain: nil) and return
        end
      end
    end
    @session = UserSession.new
    render :action => :login
  end

  def resend_activation
    @user = User.find_by_login params[:user_session][:login]
    if @user
      if @user.active?
        flash[:error] = t("user_already_active")
      else
        @user.send_activation_instructions!(request.env["SERVER_NAME"])
        flash[:success] = t("activation_sent_successful")
      end
    else
      flash[:error] = t("user_not_found")
    end
    @session = UserSession.new
    render :action => :login
  end
  
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id], 1.week)
    unless @user
      flash[:error] = t("missing_account")
      redirect_to login_url(subdomain: nil, protocol: login_protocol)
    end
  end

  def set_domain
    current_domain = request.host.split('.').last(request.session_options[:tld_length].to_i).join('.')
    request.session_options[:domain] = ".#{current_domain}"
  end

end
