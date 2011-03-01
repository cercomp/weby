# coding: utf-8
module ApplicationHelper
  include SemanticFormHelper

  def session_user
    @session_user ||= User.find(:first, :conditions => ['id = ?', session[:user]])
  end

  # Alterna entre habilitar e desabilitar registro
  # Parâmetros: obj (Objeto), publish (Campo para alternar)
  # Campo com imagens V ou X para habilitar/desabilitar e degradê se não tiver permissão para alteração.
  def toggle_field(obj, field)
    menu = ""
    if current_user.is_admin
      if obj[field.to_s] == 0 or not obj[field.to_s]
        menu = link_to(image_tag("false.png", :alt => t("disable")), {:action => "toggle_field", :id => obj.id, :field => "#{field}"}, :title => t("activate_deactivate"))
      else
        menu = link_to(image_tag("true.png", :alt => t("enable")), {:action => "toggle_field", :id=> obj.id, :field => "#{field}"}, :title => t("activate_deactivate"))
      end
    else
      if obj[field.to_s] == 0 or not obj[field.to_s]
        menu = image_tag("false_off.png", :alt => t("enable"), :title => t("no_permission_to_activate_deactivate"))
      else
        menu = image_tag("true_off.png", :alt => t("disable"), :title => t("no_permission_to_activate_deactivate"))
      end
    end
    menu
  end
  # Define os menus
  # Parâmetros: Lista de menu (sons, view_ctrl=0)
  # Retorna: O menu com seus controles
  def print_menu(sons, view_ctrl=0)
    menus ||= ""
    unless sons[0].nil?
      menus += "\n<menu>"
      sons[0].each do |child|
        menus += print_menu_entry(sons, child, view_ctrl, 1)
      end
      menus += "\n</menu>\n"
    end
    menus
  end
	# Método recursivo para gerar submenus e os controles
  def print_menu_entry(sons, entry, view_ctrl, indent=0)
    indent_space = " " * indent
    indent += 2
    submenu = (not sons[entry.id].nil?) ? "class='sub'" : nil

    menus ||= ""
    menus += "\n" + indent_space + "<li #{submenu}>" + link_to("#{entry.menu.title}", entry.menu.page_id ? site_page_path(@site, "#{entry.menu.page_id}") :"#{entry.menu.link}")
    if view_ctrl == 1
      # Se existir um position nulo ele será organizado e todos do seu nível
      if entry.position.nil? or entry.position.to_i < 1
        sons[entry.parent_id].each_with_index do |item, idx|
          #menus += " (item.id:#{item.id} entry.id:#{entry.id} idx:#{idx+1}) "
          if item.id == entry.id
           entry.update_attribute(:position, idx+1)
            entry.position = idx+1
          end
        end
      end
      #menus += " [ id:#{entry.id} pos:#{entry.position} ]" # Para debug
      menus += indent_space + link_to(image_tag('editar.gif', :border => 0, :alt => t("edit")), edit_site_menu_path(@site.name, entry.menu_id), :title => t("edit"))
      menus += indent_space + link_to(image_tag('subitem.gif', :border => 0, :alt => t("add_sub_menu")), new_site_menu_path(@site.name, :parent_id => entry.id), :title => t("add_sub_menu"))
      menus += indent_space + link_to(image_tag('setaup.gif', :border => 0, :alt => t("move_menu_up")), change_position_site_menus_path(:id => entry.id, :position => (entry.position.to_i - 1)), :title => t("move_menu_up")) if entry.position.to_i > 1
      menus += indent_space + link_to(image_tag('setadown.gif', :border => 0, :alt => t("move_menu_down")), change_position_site_menus_path(:id => entry.id, :position => (entry.position.to_i + 1)), :title => t("move_menu_down")) if (entry.position.to_i < sons[entry.parent_id].count.to_i)
      menus += indent_space + link_to(image_tag('apagar.gif', :border => 0, :alt => t("destroy")), rm_menu_site_menus_path(:id => entry.id), :confirm => t('are_you_sure'), :title => t("destroy"))
    end
    menus += "\n" + indent_space + " <menu>" unless submenu.nil?
    if sons[entry.id].class.to_s == "Array"
      sons[entry.id].each do |child|
        menus += print_menu_entry(sons, child, view_ctrl, indent+1)
      end
    end
    menus += "\n" + indent_space + " </menu>" unless submenu.nil?
    menus += "\n" + indent_space + "</li>" unless submenu.nil?
    menus += "</li>" if submenu.nil?
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
  # Parâmetros: (Objeto) ctrl, (array) actions
  # Retorna: verdadeiro ou falso
  def check_permission(ctrl, actions)
    # Se o usuário for admin então dê todas as permissões
    if current_user and current_user.is_admin
      return true
    elsif current_user and @site
      # Obtem todos os papéis do usuário relacionados com site
      current_user.roles.where(:site_id => @site).each do |role|
      # Obtem qualquer papél do usuário
      #current_user.roles.each do |role| 
        # Obtem o campo multi-valorados contendo todos os direitos
        role.rights.each do |right|
          # Controlador do usuario (right.controller) = nome do controlador recebido como parâmetro (ctr.controller_name)
          if right.controller == ctrl.controller_name
            # Cria o vetor ri com todos os direitos do usuário
            right.action.split(' ').each do |ri|
              actions.each do |action|
                # Verifica:
                # 1. Se a ação existe no controlador (Caso o usuário tenha adicionado nome incorreto)
                # 2. Direito do usuário (ri) = ação recebida como parâmetro (action)
                if ctrl.instance_methods(false).include?(action.to_sym) and ri.to_s == action.to_s
                  return true
                end
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
    user ||= current_user
    # Se não está logado não existe permissões
    return [] if user.nil?
    perms = []
    perms_user = []
    ctr = ctr.empty? ? controller.controller_name : ctr
    if user.is_admin
      return controller.class.instance_methods(false)
    else
      user.roles.where(:site_id => @site).each do |role|
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
      elsif args[:only]
        perms = args[:only] & perms_user
      end
      return perms
    end
    return perms_user
  end

  # Monta o menu baseado nas permissões do usuário
  # Parametros: objeto
  def make_menu(obj, args={})
    menu ||= ""
    get_permissions(current_user, '', args).each do |permission|
      if controller.class.instance_methods(false).include?(permission.to_sym)
        case permission.to_s
          when "show"
            menu += link_to(t('show'), {:controller => "#{controller.controller_name}", :action => 'show', :id => obj.id}, :class => 'icon icon-show', :alt => t('show'), :title => t('show')) + " "
          when "edit"
            menu += link_to(t("edit"), {:controller => "#{controller.controller_name}", :action => "edit", :id => obj.id}, :class => 'icon icon-edit', :alt => t('edit'), :title => t('edit')) + " "
          when "destroy"
            menu += link_to((t"destroy"), {:controller => "#{controller.controller_name}", :action => "destroy", :id => obj.id}, :class => 'icon icon-del', :confirm => t('are_you_sure'), :method => :delete, :alt => t('destroy'), :title => t('destroy')) + " "
        end
      end
    end
    menu
  end

  def adminnav(site=nil)
    adminnav = "<nav id=\"admin\">\n\t"
    adminnav += link_to( t("portal"), root_path )
    adminnav += " | \n\t"

    if site
      adminnav += link_to( t("home"), site )
      adminnav += " | \n\t"
      adminnav += link_to( t("admin.one"), site_admin_index_path(site) )
      adminnav += " | \n\t"
    else
      adminnav += link_to( t("admin.one"), admin_index_path )
      adminnav += " | \n\t"
    end

    unless current_user
      adminnav += link_to( t("register"), new_user_path )
      adminnav += " | \n\t"
      adminnav += link_to( t("login"), login_path(:back_url => "#{request.fullpath}"))
      adminnav += " | \n\t"
    else
      adminnav += site ? link_to(t("my_profile"), site_user_path(site, current_user)) : link_to(t("my_profile"), user_path(current_user))
      adminnav += " | \n\t"
      adminnav += link_to( t("logout"), logout_path, :confirm => t("are_you_sure") )
      adminnav += "\n\t"
    end

    adminnav += User.logged_in.count.to_s + ' ' + t('user', :count => User.logged_in.count) + ' ' + t('logged') + ".\n"
    adminnav += "</nav>"
    adminnav
  end

end
