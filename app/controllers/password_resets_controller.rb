# coding: utf-8
class PasswordResetsController < ApplicationController
  layout :choose_layout

  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  
  before_filter :require_no_user  

  skip_before_filter :check_authorization

  def new
    render
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user && @user.deliver_password_reset_instructions!
      send_email_password_reset
      flash[:notice] = t("reset_mail")
      redirect_to root_url
    else
      flash.now[:warning] = t("no_mail")
      render :action => :new
    end
  end
  
  def edit  
    render  
  end  
  
  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save  
      flash[:notice] = t"succesfully_updated", :param => t("password")
      redirect_to account_url  
    else  
      render :action => :edit  
    end  
  end  
  
  private  
    def load_user_using_perishable_token  
      @user = User.find_using_perishable_token(params[:id])  
      unless @user  
        flash[:notice] = t("missing_account")
        redirect_to root_url  
      end  
    end  

    #Envia email (instruções para recuperar a senha)
    def send_email_password_reset
      corpo = <<-CODE
      <b>Instruções para trocar a senha a senha<br></b>
      <b>Login: </b>#{@user.login}<br>
      <b>E-mail: </b>#{@user.email}<br>
      <b>Para trocar a senha <b>Link: </b><a href='#{edit_password_reset_url(@user.perishable_token)}'>clique aqui.</a>
      CODE

      Email.deliver_padrao(:corpo => corpo, :assunto => t("instructions_change_password"), :para => @user.email)
  end     

end
