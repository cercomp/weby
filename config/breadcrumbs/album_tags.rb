# album tags
crumb :album_tags do
  link t('extensions.gallery.name'), site_admin_albums_path
  link t('breadcrumbs.album_tags'), site_admin_album_tags_path
end

crumb :album_tags_new do
  link t('breadcrumbs.new_album_tag'), new_site_admin_album_tag_path
  parent :album_tags
end

crumb :album_tags_edit do |album_tag|
  link "#{t('breadcrumbs.edit')} #{album_tag.name}", edit_site_admin_album_tag_path(album_tag)
  parent :album_tags
end

crumb :album_tags_show do |album_tag|
  link "#{album_tag.name}", site_admin_album_tag_path
  parent :album_tags
end

