module ApplicationHelper

  def session_user
    @session_user ||= User.find(:first, :conditions => ['id = ?', session[:user]])
  end

  def flash_message
    messages = ""
    [:notice, :info, :warning, :error].each {|type|
      if flash[type]
        messages += "<div class=\"flash #{type}\">#{flash[type]}</div>"
      end}
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
