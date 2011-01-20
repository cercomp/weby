# coding: utf-8
module ApplicationHelper

  def session_user
    @session_user ||= User.find(:first, :conditions => ['id = ?', session[:user]])
  end

  def menu_change_status(ctrl, user ,obj, parameter)
    menu = ""
    if current_user.is_admin || check_permission(ctrl, "change_status")
      if obj != true or !obj
        menu << (link_to image_tag("false.png", :title => t("activate_deactivate"), :alt => "Inativo"), :url => { :action => "change_status", :id => user.id, :status => 1, :field => parameter })
      else
        menu << (link_to image_tag("true.png", :title =>  t("activate_deactivate"), :alt => "Ativo"), :url => { :action => "change_status", :id=> user.id, :status => 0, :field => parameter })
      end
    else
      if obj != true or !obj
        menu << image_tag("false_off.png", :title => t("no_permission_to_activate_deactivate"), :alt => "Inativo")
      else
        menu << image_tag("true_off.png", :title => t("no_permission_to_activate_deactivate"), :alt => "Ativo")
      end
    end
    menu
  end
  # Define os menus
  # Parâmetros: Lista de menu (sons, view_ctrl=0)
  # Retorna: O menu com seus controles
  def print_menu(sons, view_ctrl=0)
    menus ||= ""
    unless sons["0"].nil?
      sons["0"].each do |child|
        #menus += "<menu>"
        menus += print_menu_entry(sons, child, view_ctrl, 1)
        #menus += "</menu>"
      end
    end
    menus
  end
	# Método recursivo para gerar submenus e os controles
  def print_menu_entry(sons, entry, view_ctrl, indent=0)
    indent_space = "  " * indent
    submenu = (not sons["#{entry.id}"].nil?) ? "class='sub'" : nil

    menus ||= ""
    menus += indent_space + "<li #{submenu}>" + link_to("#{entry.title}", "#{entry.link}") + "\n"
    if view_ctrl == 1
      menus += indent_space + link_to(image_tag('editar.gif', :border => 0), edit_site_menu_path(@site.name, entry.menu_id))
      menus += indent_space + link_to(image_tag('subitem.gif', :border => 0), new_site_menu_path(@site.name, :parent_id => entry.id))
      menus += indent_space + link_to(image_tag('setaup.gif', :border => 0), {:controller => 'menus', :action => 'change_position', :id => entry.id, :position => (entry.position.to_i - 1)}, :method => :get) if entry.position.to_i > 1
      menus += indent_space + link_to(image_tag('setadown.gif', :border => 0), {:controller => 'menus', :action => 'change_position', :id => entry.id, :position => (entry.position.to_i + 1)}, :method => :get) if (entry.position.to_i < sons[entry.parent_id].count.to_i)
      menus += indent_space + link_to(image_tag('apagar.gif', :border => 0), {:controller => 'menus', :action => 'rm_menu', :id => entry.id}, :confirm => t('are_you_sure'), :method => :get) + "\n"
    end
    menus += indent_space + "  <menu>\n" unless submenu.nil?
    if sons["#{entry.id}"].class.to_s == "Array"
      sons["#{entry.id}"].each do |child|
        menus += print_menu_entry(sons, child, view_ctrl, indent+2)
      end
    end
    menus += indent_space + "  </menu>\n" unless submenu.nil?
    menus += indent_space + "</li>\n"
    menus
  end

  # Define mensagens personalizadas
  def flash_message
    messages = ""
    [:notice, :info, :warning, :error].each do |type|
      if flash[type]
        messages += "<div class=\"flash #{type}\">#{flash.now[type]}</div>"
      end
    end
    messages
  end

  # Verifica se o usuário tem permissão no controlador e na ação passada como parâmetro
  # Parâmetros: (Objeto) ctrl, (string) action
  # Retorna: verdadeiro ou falso
  def check_permission(ctrl, action)
    # Se o usuário for admin então dê todas as permissões
    if current_user and current_user.is_admin
      return true
    elsif current_user
      user_obj = User.find(current_user.id)
      # Obtem todos os papéis do usuário
      user_obj.roles.each do |role|
        # Obtem o campo multi-valorados contendo todos os direitos
        role.rights.each do |right|
          # Controlador do usuario (right.controller) = nome do controlador recebido como parâmetro (ctr.controller_name)
          if right.controller == ctrl.controller_name
            # Cria a vetor ri com todos os direitos do usuário
            right.action.split(' ').each do |ri|
              # Verifica:
              # 1. Se a ação existe no controlador (Caso o usuário tenha adicionado nome incorreto)
              # 2. Direito do usuário (ri) = ação recebida como parâmetro (action)
              if ctrl.instance_methods(false).include? action and ri == action
                return true
              end
            end
          end
        end
      end
      return false
    end
  end

  # Verifica as permissões do usuário dado um controlador
  # Parametros: (objeto) usuário, (string) controlador
  # Retorna: um vetor com as permissões
  def get_permissions(user, ctr, args={})
    perms = []
    perms_user = []
    user = user.nil? ? current_user : user
    ctr  = ctr.empty? ? controller.controller_name : ctr
    if user.is_admin
      controller.class.instance_methods(false).each{ |ri| perms_user << ri }
      return perms_user
    else
      user.roles.each do |role|
        role.rights.each do |right|
          if right.controller == ctr
            right.action.split(' ').each{ |ri| perms_user << ri }
          end
        end
      end
    end
    if args.length > 0
      if args[:except]
        perms = (controller.class.instance_methods(false) - args[:except]) & perms_user
      else
        perms = args[:only] & perms_user
      end
    end
    return perms
  end

  # Monta o menu baseado nas permissões do usuário
  # Parametros: objeto
  def make_menu(obj, args={})
    menu = ""
    get_permissions(current_user, '', args).each do |permission|
      if controller.class.instance_methods(false).include? permission
        case permission.to_s
          when "show"
            menu << link_to( t('show'), {:controller => "#{controller.controller_name}", :action => 'show', :id => obj.id}, :class => 'icon icon-show')+' '
          when "edit"
            menu << link_to( t("edit"), {:controller => "#{controller.controller_name}", :action => "edit", :id => obj.id}, :class => 'icon icon-edit')+' '
          when "destroy"
            menu << link_to( (t"remove", :param => ''), {:controller => "#{controller.controller_name}", :action => "destroy", :id => obj.id}, :class => 'icon icon-del', :confirm => t('are_you_sure'), :method => :delete)+' '

        end
      end
    end
    menu
  end

end
