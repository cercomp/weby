module CssesHelper

  # Monta o menu baseado nas permissões do usuário
  def make_menu(obj, args={})
    menu ||= ""
    get_permissions(current_user, '', args).each do |permission|
      if controller.class.instance_methods(false).include?(permission.to_sym)
        case permission.to_s
          when "use_obj"
            menu += link_to t('use'), {:action => 'use_obj', :id => css.id }, :class => 'icon icon-fav', :alt => t("enable"), :title => t("activate_deactivate")
            # link_to t('use'), nil, :class => 'icon icon-fav-off', :alt => t("disable"), :title => t("no_permission_to_activate_deactivate")
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

end
