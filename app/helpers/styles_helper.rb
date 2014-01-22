module StylesHelper
  def style_actions(style, args={others: false, follow: false})
    ''.tap do |actions|

      excepts = args[:except] || []
      # Transforma o parâmetro em array caso não seja
      excepts = [excepts] unless excepts.is_a? Array
      excepts.each_index do |i|
        # Transforma parâmetros em símbolos caso não sejam
        excepts[i] = excepts[i].to_sym unless excepts[i].is_a? Symbol
      end
      #não criar menu para objetos de outro site
      excepts.concat [:edit, :destroy] if style.owner_id != current_site.id
      (controller.class.instance_methods(false) - excepts).each do |action|
        if test_permission(controller.class, action)
          if args[:others]
            case action.to_s
            when 'follow'
              if args[:follow]
                actions << link_to( icon('star-empty', text: t('unfollow')), unfollow_site_admin_style_path(style )) + ' '
              else
                actions << link_to( icon('star', text: t('follow')), follow_site_admin_style_path(style)) + ' '
              end
            when 'copy'
              actions << link_to( icon('hdd', text: t('copy')), copy_site_admin_style_path(style)) + ' '
            end
          else
            case action.to_s
            when 'edit'
              actions << link_to( icon('edit', text: t('edit')), edit_site_admin_style_path(style)) + ' '
            when 'destroy'
              actions << (link_to( icon('trash', text: t('destroy')), site_admin_style_path(style),
                                data: {confirm: t('are_you_sure')}, method: :delete ) + ' ') if style.followers.empty?
            end
          end
        end
      end
    end
  end

  # Alterna entre habilitar e desabilitar registro
  # Parâmetros: obj (Objeto), field (Campo para alternar), action (Ação a ser executada no controller)
  # Campo com imagens V ou X para habilitar/desabilitar e degradê se não tiver permissão para alteração.
  def toggle_field_style(obj, field, action='toggle_field', options = {})
    ''.tap do |menu|
      if check_permission(controller.class, "#{action}")
        obj_temp = check_if_style(obj)
        if obj_temp[field.to_s] == 0 or not obj_temp[field.to_s]
          menu <<  link_to( check_box_tag(t("disable"), action.to_s, false, alt: t("disable")),
                            {:action => "#{action}", :id => obj.id, :field => "#{field}"},
                            options.merge({method: :put, :title => t("unpublished")}))
          menu << " #{t('publish')}" if options[:show_label]
        else
          menu << link_to( check_box_tag(t("enable"), action.to_s, true, :alt => t("enable")),
                           {:action => "#{action}", :id=> obj.id, :field => "#{field}"},
                           options.merge({method: :put, :title => t("published")}))
          menu << " #{t('publish')}" if options[:show_label]
        end
      else        
        if obj[field.to_s] == 0 or not obj[field.to_s]
          menu << image_tag("false_off.png", :alt => t("enable"), :title => t("no_permission_to_activate_deactivate"))
          menu << " #{t('unpublished')}" if options[:show_label]
        else
          menu << image_tag("true_off.png", :alt => t("disable"), :title => t("no_permission_to_activate_deactivate"))
          menu << " #{t('published')}" if options[:show_label]
        end
      end
      print menu
    end
  end

  def check_if_style(obj)
    if obj.is_a? Style
      if obj.owner != current_site
        return obj.sites_styles.where(site_id: @site.id)[0]
      else
        return obj
      end
    end
    return obj
  end
  private :check_if_style


end
