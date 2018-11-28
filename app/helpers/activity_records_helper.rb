module ActivityRecordsHelper
  def build_loggeable_url activity_record
    return nil unless activity_record.is_linkable?

    case activity_record.loggeable
    when Journal::News
      admin_news_url(activity_record.loggeable, subdomain: activity_record.site)
    when Sticker::Banner
      admin_banner_url(activity_record.loggeable, subdomain: activity_record.site)
    when Calendar::Event
      admin_event_url(activity_record.loggeable, subdomain: activity_record.site)
    when Skin, Site
      site_admin_skins_url(subdomain: activity_record.site)
    else
      polymorphic_url(loggeable_array(activity_record), subdomain: activity_record.site)
    end
  end

  private

  def loggeable_array activity_record
    prefix = activity_record.site ? :site_admin : :admin
    case activity_record.controller
    when 'menu_items'
      [prefix, activity_record.loggeable.menu, activity_record.loggeable]
    when 'components', 'styles'
      [prefix, activity_record.loggeable.skin, activity_record.loggeable]
    else
      [prefix, activity_record.loggeable]
    end
  end
end
