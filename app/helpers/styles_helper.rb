module StylesHelper
  def style_actions(style, args={others: false, follow: false})
    ''.tap do |actions|
      get_permissions( current_user, controller: controller.class ).each do |permission|
        if controller.class.instance_methods(false).include?(permission.to_sym)
          if args[:others]
            case permission.to_s
            when 'show'
              actions << link_to( t('show'), site_admin_style_path(@site, style)) + ' '
            when 'publish'
              actions << style_action_publish(style) + ' ' if args[:follow]
            when 'follow'
              if args[:follow]
                actions << link_to( t('unfollow'), unfollow_site_admin_style_path(@site, style )) + ' '
              else
                actions << link_to( t('follow'), follow_site_admin_style_path(@site, style)) + ' '
              end
            when 'copy'
              actions << link_to( t('copy'), copy_site_admin_style_path(@site, style)) + ' '
            end
          else
            case permission.to_s
            when 'publish'
              actions << style_action_publish(style) + ' '
            when 'show'
              actions << link_to( t('show'), site_admin_style_path(@site, style)) + ' '
            when 'edit'
              actions << link_to( t('edit'), edit_site_admin_style_path(@site, style)) + ' '
            when 'destroy'
              actions << (link_to( t('destroy'), site_admin_style_path(@site, style),
                                confirm: t('are_you_sure'), method: :delete ) + ' ') if style.followers.empty?
            end
          end
        end
      end
    end
  end

  def style_action_publish style
    if style.owner != @site
      relation = style.sites_styles.where(site_id: @site.id).first
    else
      relation = style
    end

    if relation.publish
      link_to( t('unpublish'), unpublish_site_admin_style_path(@site, style) ) + ' '
    else
      link_to( t('publish'), publish_site_admin_style_path(@site, style)) + ' '
    end
  end
end
