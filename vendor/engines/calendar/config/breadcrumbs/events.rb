# extensions:events
crumb :events do
  link t('breadcrumbs.events'), admin_events_path
end

crumb :events_new do
  link t('breadcrumbs.new_event'), new_admin_event_path
  parent :events
end

crumb :events_show do |event|
  link "#{event.name}", admin_event_path(event)
  parent :events
end

crumb :events_edit do |event|
  link "#{t('breadcrumbs.edit')} #{event.name}", edit_admin_event_path(event)
  parent :events
end

crumb :events_search do |search|
  link "#{t('breadcrumbs.search')}/ #{search}"
  parent :events
end

crumb :events_recycle_bin do
  link t('recycle_bin')
  parent :events
end
