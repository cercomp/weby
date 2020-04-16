module ActivityRecordsHelper
  def build_loggeable_url activity_record
    return nil unless activity_record.is_linkable?

    case activity_record.loggeable_type
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
    else
      loggeable_url(activity_record)
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
