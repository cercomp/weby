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
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +
      "Please check your email."
      redirect_to root_url
    else
      flash[:notice] = "No user was found with that email address"
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
      flash[:notice] = "Password successfully updated"  
      redirect_to account_url  
    else  
      render :action => :edit  
    end  
  end  
  
  private  
    def load_user_using_perishable_token  
      @user = User.find_using_perishable_token(params[:id])  
      unless @user  
        flash[:notice] = "We're sorry, but we could not locate your account. " +  
        "If you are having issues try copying and pasting the URL " +  
        "from your email into your browser or restarting the " +  
        "reset password process."  
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

      Email.deliver_padrao(:corpo => corpo, :assunto => "Instruções para trocar a senha", :para => @user.email)
  end     

end
