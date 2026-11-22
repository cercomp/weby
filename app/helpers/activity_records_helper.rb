module ActivityRecordsHelper
  def build_loggeable_url activity_record
    return nil unless activity_record.is_linkable?
    case activity_record.loggeable_type
    when 'Repository'
      if activity_record.loggeable
        main_app.site_admin_repository_url(activity_record.loggeable_id, subdomain: activity_record.site)
      else
        main_app.site_admin_repositories_url(subdomain: activity_record.site)
      end
    when 'Journal::News'
      if activity_record.loggeable
        admin_news_url(activity_record.loggeable_id, subdomain: activity_record.site)
      else
        admin_news_index_url(subdomain: activity_record.site)
      end
    when 'Sticker::Banner'
      if activity_record.loggeable
        admin_banner_url(activity_record.loggeable_id, subdomain: activity_record.site)
      else
        admin_banners_url(subdomain: activity_record.site)
      end
    when 'Calendar::Event'
      if activity_record.loggeable
        admin_event_url(activity_record.loggeable_id, subdomain: activity_record.site)
      else
        admin_events_url(subdomain: activity_record.site)
      end
    when 'Page'
      if activity_record.loggeable
        main_app.site_admin_page_url(activity_record.loggeable_id, subdomain: activity_record.site)
      else
        main_app.site_admin_pages_url(subdomain: activity_record.site)
      end
    when 'Site'
      main_app.site_admin_url(subdomain: activity_record.loggeable)
    when 'Component'
      if activity_record.loggeable
        main_app.site_admin_skin_url(activity_record.loggeable.skin_id, subdomain: activity_record.site)
      else
        main_app.site_admin_skins_url(subdomain: activity_record.site)
      end
    when 'Style'
      if activity_record.loggeable
        main_app.site_admin_skin_style_url(activity_record.loggeable.skin_id, activity_record.loggeable_id, subdomain: activity_record.site)
      else
        main_app.site_admin_skins_url(subdomain: activity_record.site, anchor: 'tab-styles')
      end
    when 'AlbumPhoto'
      if activity_record.loggeable
        main_app.site_admin_album_album_photo_url(activity_record.loggeable.album_id, activity_record.loggeable_id, subdomain: activity_record.site)
      else
        main_app.site_admin_albums_url(subdomain: activity_record.site)
      end
    else
      loggeable_url(activity_record)
    end
  end

  def activity_action_badge(activity_record)
    note = activity_record.note.to_s
    action = activity_record.action.to_s

    icon_name = 'cog'
    badge_class = 'label-default'
    action_text = t(".#{note}", default: note.humanize)

    if note == 'uploaded_file'
      icon_name = 'upload'
      badge_class = 'label-success'
      action_text = t('.uploaded_file', default: 'Upload de Arquivo')
    elsif note =~ /created_/ || action == 'create'
      icon_name = 'plus-circle'
      badge_class = 'label-success'
      action_text = t('.created', default: 'Criação')
    elsif note =~ /updated_/ || action == 'update'
      icon_name = 'pencil'
      badge_class = 'label-info'
      action_text = t('.updated', default: 'Edição')
    elsif note =~ /destroy|recycle_bin/ || action == 'destroy'
      icon_name = 'trash'
      badge_class = 'label-danger'
      action_text = t('.deleted', default: 'Exclusão / Lixeira')
    elsif note =~ /restored_/
      icon_name = 'undo'
      badge_class = 'label-warning'
      action_text = t('.restored', default: 'Restauração')
    elsif note =~ /shared_/
      icon_name = 'share-alt'
      badge_class = 'label-primary'
      action_text = t('.shared', default: 'Compartilhamento')
    end

    content_tag(:span, class: "label #{badge_class}") do
      "#{fa_icon(icon_name)} #{action_text}".html_safe
    end
  end

  def activity_item_view(activity_record)
    title = activity_record.target_title
    is_deleted = activity_record.item_deleted?
    url = build_loggeable_url(activity_record)

    icon_class = case activity_record.loggeable_type
                 when 'Repository'
                   'fa-file-image-o'
                 when 'Journal::News'
                   'fa-newspaper-o'
                 when 'Page'
                   'fa-file-text-o'
                 when 'Component'
                   'fa-cogs'
                 when 'Menu', 'MenuItem'
                   'fa-bars'
                 when 'User'
                   'fa-user'
                 when 'Skin'
                   'fa-paint-brush'
                 else
                   'fa-cube'
                 end

    content = ''.tap do |html|
      html << "<i class=\"fa #{icon_class} text-muted\" style=\"margin-right: 4px;\"></i>"
      if url.present? && !is_deleted
        html << link_to(title, url, class: 'action-link font-weight-bold')
      else
        html << "<strong>#{h(title)}</strong>"
      end

      if is_deleted
        html << " <span class=\"text-muted small\"><em>(#{t('.deleted_item', default: 'Item excluído')})</em></span>"
      end
    end.html_safe

    content
  end

  def activity_user_view(activity_record)
    user = activity_record.user
    return content_tag(:span, t('.system', default: 'Sistema'), class: 'text-muted') unless user

    name = user.fullname.presence || "#{user.first_name} #{user.last_name}".strip
    name = user.login if name.blank?

    content_tag(:span) do
      "<i class=\"fa fa-user text-muted\"></i> #{h(name)} <small class=\"text-muted\">(#{h(user.login)})</small>".html_safe
    end
  end

  private

  def loggeable_url activity_record
    case activity_record.controller
    when 'menu_items'
      opts = {subdomain: activity_record.site}
      if activity_record.loggeable
        opts[:menu] = activity_record.loggeable.menu_id
      end
      main_app.site_admin_menus_url(opts)
    else
      prefix = activity_record.site ? :site_admin : :admin
      polymorphic_url([prefix, activity_record.loggeable], subdomain: activity_record.site)
    end
  end
end
