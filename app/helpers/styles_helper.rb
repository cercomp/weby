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
            when 'show'
              actions << link_to( icon('eye-open', text: t('show')), site_admin_style_path(style)) + ' '
            when 'publish'
              actions << style_action_publish(style) + ' ' if args[:follow]
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
            when 'publish'
              actions << style_action_publish(style) + ' '
            when 'show'
              actions << link_to( icon('eye-open', text: t('show')), site_admin_style_path(style)) + ' '
            when 'edit'
              actions << link_to( icon('edit', text: t('edit')), edit_site_admin_style_path(style)) + ' '
            when 'remove'
              actions << (link_to( icon('trash', text: t('remove')), remove_site_admin_style_path(style),
                                data: {confirm: t('are_you_sure')}) + ' ') if style.followers.empty?
            when 'destroy'
              actions << (link_to( icon('fire', text: t('destroy')), site_admin_style_path(style),
                                data: {confirm: t('are_you_sure')}, method: :delete ) + ' ') if style.followers.empty?
            end
          end
        end
      end
    end
  end

  def style_action_publish style
    if style.owner != current_site
      relation = style.sites_styles.where(site_id: current_site.id).first
    else
      relation = style
    end

    if relation.publish
      link_to( icon('remove-circle', text: t('unpublish')), unpublish_site_admin_style_path(style) ) + ' '
    else
      link_to( icon('ok-circle', text: t('publish')), publish_site_admin_style_path(style)) + ' '
    end
  end
end
