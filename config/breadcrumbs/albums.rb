# albums
crumb :albums do
  link t('breadcrumbs.albums'), site_admin_albums_path
end

crumb :albums_new do
  link t('breadcrumbs.new_album'), new_site_admin_album_path
  parent :albums
end

crumb :albums_edit do |album|
  link "#{t('breadcrumbs.edit')} #{album.title}", edit_site_admin_album_path
  parent :albums
end

crumb :albums_show do |album|
  link "#{album.title}", site_admin_album_path
  parent :albums
end

crumb :albums_search do |search|
  link "#{t('breadcrumbs.search')}/ #{search}"
  parent :albums
end

crumb :albums_photos do |album|
  link t('breadcrumbs.album_photos')
  parent :albums_edit, album
end
