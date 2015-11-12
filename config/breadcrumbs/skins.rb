# skins
crumb :skins do
  link t('breadcrumbs.choose_theme'), site_admin_skins_path
  parent :themes
end

# crumb :styles_new do
#   link t('breadcrumbs.new_style'), new_site_admin_skin_path
#   parent :styles
# end

crumb :skins_show do |skin|
  link "#{skin.name}", site_admin_skin_path(skin)
  parent :skins
end

# crumb :skins_edit do |skin|
#   link "#{t('breadcrumbs.edit')} #{style.name}", edit_site_admin_style_path
#   parent :styles
# end

crumb :skins_search do
  link t('breadcrumbs.search')
  parent :skins
end
