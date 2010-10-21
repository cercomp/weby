# coding: utf-8

class UsersController < ApplicationController
  layout :choose_layout

  before_filter :require_user, :only => [:edit, :show, :destroy, :update, :change_status, :change_roles, :change_theme]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :check_authorization, :except => [:new, :create]

  respond_to :html, :xml

  def change_theme
    if params[:id] && current_user
      @user = User.find(current_user.id)
      @user.update_attribute(:theme, params[:id])
      flash[:notice] = t:look_changed
    end
    redirect_back_or_default root_path
  end

  def change_roles
    if params[:role_id] && params[:user_id]
      @r = RolesUser.delete_all(["user_id = ?", params[:user_id]])
      @r = RolesUser.create :user_id => params[:user_id], :role_id => params[:role_id]
      flash[:notice] = t'uso', :param => t('role')
    end
    redirect_back_or_default users_path
  end

  def index
    @users = User.paginate :page => params[:page], :order => 'id DESC', :per_page => 10
    @roles = Role.find(:all, :select => 'id,name,theme', :group => "name,id,theme", :order => "id")
    respond_with(@user)
  end

  def new
    @user = User.new
    files = []
    for file in Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*")]
      files << file.split("/")[-1].split(".")[0]
    end
    @themes = files
    respond_with(@user)
  end
  
  def create
    @user = User.new(params[:user])
    files = []
    for file in Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*")]
      files << file.split("/")[-1].split(".")[0]
    end
    @themes = files
    
    if @user.save
      flash[:notice] = "Conta registrada!"
      redirect_to users_path
    else
      render :action => :new
    end
  end
  
  def show
    @user = User.find(params[:id])
    respond_with(@user)
  end

  def edit
    @user = User.find(params[:id])
    files = []
    for file in Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*")]
      files << file.split("/")[-1].split(".")[0]
    end
    @themes = files
    respond_with(@user)
  end
  
  def update
    unless current_user.is_admin
      params[:id] = current_user.id
    end
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    flash[:notice] = t"updated", :param => t("account")
    respond_with(@user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_with(@user)
  end

  def change_status
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attribute(params[:field], params[:status])
        format.html {
          render :update do |page|
            page.reload
          end
        }
      end
    end
  end

 private
  #Envia email (usuário ativar usuário)
  def send_email_active_user
    corpo = <<-CODE
    <b>Seu cadastro precisa ser confirmado<br></b>
    <b>Data do cadastro: </b>#{@user.created_at}<br>
    <b>Login: </b>#{@user.login}<br>
    <b>E-mail: </b>#{@user.email}<br>
    <b>Para ativar </b><a href='#{edit_active_user_url(@user.perishable_token)}'>clique aqui.</a>
    CODE

    Email.deliver_padrao(:corpo => corpo, :assunto => "Cadastro Aceito", :para => @user.email)
  end   
end
