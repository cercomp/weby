# coding: utf-8
class Sites::Admin::UsersController < ApplicationController
  include UserCommon
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
end
