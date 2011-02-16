# coding: utf-8
class UsersController < ApplicationController
  layout :choose_layout

  before_filter :require_user, :only => [:edit, :show, :update, :destroy, :toggle_field, :change_roles, :change_theme, :index]
  before_filter :check_authorization, :except => [:new, :create, :update, :edit, :show]

  respond_to :html, :xml

  def change_theme
    if params[:id] && current_user
      @user = User.find(current_user.id)
      @user.update_attribute(:theme, params[:id])
      flash[:notice] = t("look_changed")
    end
    redirect_back_or_default root_path
  end

  def manage_roles
    # Se a ação for selecionada para um site:
    unless @site.nil?
      @users = User.find(:all)
      @users_unroled = @users - @site.users
      @roles = Role.find(:all, :order => "id")

			respond_with do |format|
				format.js do
					render :update do |page|
						page.call "$('#enroled').html", render('enroled')
						page.call "$('#enrole').html", render('enrole')
					end
				end

				format.html
			end

    else
      @sites = Site.find(:all)
      render :select_site
    end
  end

  def change_roles
    params[:role_ids] ||= []
    user_ids = []
    user_ids.push(params[:user][:id]).flatten!

    user_ids.each do |id|
      user = User.find(id)

      # limpa os papeis do usuário
      user.user_site_enroled.where(:site_id => @site.id).each{ |role| role.destroy }

      params[:role_ids].each do |role_id|
        user.user_site_enroled << UserSiteEnroled.new(
                                      :site_id => @site.id,
                                      :user_id => user.id,
                                      :role_id => role_id)
      end
    end

    redirect_to :action => 'manage_roles'
    
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

  def toggle_field
    @user = User.find(params[:id])
    if params[:field] 
      if @user.update_attributes("#{params[:field]}" => (@user[params[:field]] == 0 or not @user[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_back_or_default users_path(@site)
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
