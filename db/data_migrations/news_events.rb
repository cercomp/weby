print('Updating Roles...')
Role.find_each do |role|
  if role.permissions && role.permissions.match(/^{/)
    perm = eval(role.permissions)

    next if perm['pages'].blank?
    actions = perm['pages'].dup

    perm['news'] = actions.dup
    actions.delete('sort')
    perm['events'] = actions
    perm['pages'] = actions
    role.update_attribute :permissions, perm.to_s
  end
end
print("OK\n")
print("Updating Components...")
Component.where(name: 'front_news').find_each do |component|
  sett = eval(component.settings)
  if sett['type_filter'] == 'events'
    component.name = 'event_list'
    sett['template'] = 'front'
    sett.delete('order_by')
  end
  if sett['order_by'] == 'event_begin'
    sett['order_by'] = 'created_at'
  end
  sett.delete('type_filter')
  component.settings = sett.to_s
  component.save
end
print("OK\n")
print("Updating menu items...")
MenuItem.find_each do |item|
  news = item.target
  if !news && (match = item.url.to_s.match(/\/pages\/([0-9]+)/))
    news = Journal::News.find_by(id: match[1])
  end

  next if !news || news.front || news.site_id != item.menu.site_id || !news.is_a?(Journal::News)

  page = Page.create!(
    site_id: news.site_id,
    user_id: news.user_id,
    publish: news.status == 'published',
    deleted_at: news.deleted_at,
    view_count: news.view_count,
    created_at: news.created_at,
    updated_at: news.updated_at,
    i18ns_attributes: Journal::News::I18ns.where(journal_news_id: news.id).map do |i18n|
       {
         locale_id: i18n.locale_id,
         title: i18n.title,
         text: i18n.text
       }
     end
  )
  news.update_attribute(:url, Rails.application.routes.url_helpers.site_page_path(page))

  item.target = page
  item.url = Rails.application.routes.url_helpers.site_page_path(page)
  item.save
end
print("OK\n")
print("Updating banners...")
Sticker::Banner.find_each do |banner|
  news = banner.target
  if !news && (match = banner.url.to_s.match(/\/pages\/([0-9]+)/))
    news = Journal::News.find_by(id: match[1])
  end

  next if !news || news.site_id != banner.site_id || !news.is_a?(Journal::News)

  if match = news.url.to_s.match(/\/p\/([0-9]+)/)
    page = Page.find_by(id: match[1])
    if page
      banner.target = page
      banner.url = Rails.application.routes.url_helpers.site_page_path(page)
      banner.save
    end
  end
end
print("OK\n")
print("Installing extensions...")
Site.find_each do |s|
   s.extensions.create(name: "journal")
   s.extensions.create(name: "calendar")
 end
print("OK\n")