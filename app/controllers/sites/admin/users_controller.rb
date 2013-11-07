# coding: utf-8

class Sites::Admin::UsersController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  
  respond_to :html, :xml
  helper_method :sort_column

  def manage_roles
    # Seleciona os todos os usuários que não são administradores
    #@users = User.no_admin
    # Usuários que possuem papel no site e não são administradores
    @site_users = User.no_admin.by_site(@site).order('users.first_name asc')
    # Usuários que NÃO possuem papel no site e não são administradores
    @users_unroled = User.actives.no_admin.by_no_site(@site).order('users.first_name asc')
    # Busca os papéis do site e global
    @roles = @site.roles.order("id")
    # Quando a edição dos papeis é solicitada
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def change_roles
    params[:role_ids] ||= []
    user_ids = []
    user_ids.push(params[:user][:id]).flatten!

    user_ids.each do |user_id|
      user = User.find(user_id)
      # Limpa os papeis do usuário no site
      user.role_ids.each do |role_id|
        if @site and @site.roles.map{|r| r.id }.index(role_id)
          user.role_ids -= [role_id]
        end
      end
      
      # Se for global, limpa os papeis globais
      unless @site
        user.roles.where(site_id: nil).each{|r| user.role_ids -= [r.id] }
      end
      # NOTE Talvez seja melhor usar (user.role_ids += params[:role_ids]).uniq
      # assim removemos o each logo a cima
      user.role_ids += params[:role_ids]
    end
    redirect_to :action => 'manage_roles'
  end
end
