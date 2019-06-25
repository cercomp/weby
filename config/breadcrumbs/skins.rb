# skins
crumb :skins do
  link t('breadcrumbs.themes'), site_admin_skins_path
end

crumb :skins_new do
  link t('breadcrumbs.new_theme')
  parent :skins
end

crumb :skins_edit do
  link t('breadcrumbs.edit_theme')
  parent :skins
end

# crumb :styles_new do
#   link t('breadcrumbs.new_style'), new_site_admin_skin_path
#   parent :styles
# end

crumb :skins_show do |skin|
  link "#{skin.base_theme.title}", skin.site_id == current_site.id ? site_admin_skin_path(skin) : ''
  parent :skins
end

crumb :skins_search do
  link t('breadcrumbs.search')
  parent :skins
end
