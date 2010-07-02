module ApplicationHelper

  def session_user
    @session_user ||= User.find(:first, :conditions => ['id = ?', session[:user]])
  end

  # Define os menus
  # Parâmetros: Raiz do menu (parent_menu),  Distância da base esquerda em px (padding_left), Profundidade (depth)
  # Retorna: O menu com seus controles
  def list_menus(parent_menu, padding_left, depth)
    colors = ["#00ffff", "#85fcfc", "#baffff", "#ceffff", "#e0ffff"]
    menus = ""
    parent_menu.each do |menu|
      menus += "<div style=\"padding-left: #{padding_left * depth}px; height: 25px; background-color: #{colors[depth]};\">" + link_to(menu.title, "#{menu.link}") +
        "<div style='float: right;  white-space: nowrap;'>" +
          link_to(image_tag('editar.gif', :border => 0), edit_menu_path(menu)) +
          link_to(image_tag('subitem.gif', :border => 0), :controller => 'menus', :action => 'new', :father_id => menu.id) +
          link_to(image_tag('setaup.gif', :border => 0), new_menu_path, :father_id => menu.id) +
          link_to(image_tag('setadown.gif', :border => 0), new_menu_path, :father_id => menu.id) +
          link_to(image_tag('apagar.gif', :border => 0), menu, :confirm => 'Are you sure?', :method => :delete) +
       "</div></div>"
      menus += list_menus(Menu.where(["father_id = ?", menu.id]), padding_left, depth += 1)
      depth -= 1
    end
    return menus
  end

  # Define mensagens personalizadas
  def flash_message
    messages = ""
    [:notice, :info, :warning, :error].each do |type|
      if flash[type]
        messages += "<div class=\"flash #{type}\">#{flash[type]}</div>"
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
              if ctrl.action_methods.include? action and ri == action
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
      controller.class.action_methods.each{ |ri| perms_user << ri }
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
        perms = (controller.class.action_methods - args[:except]) & perms_user
      else
        perms = args[:only] & perms_user
      end
    end
    return perms
  end

end
