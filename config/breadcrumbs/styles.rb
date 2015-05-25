# styles
crumb :styles do
  link t('breadcrumbs.styles'), site_admin_themes_path(anchor: 'tab-styles')
  parent :themes
end

crumb :styles_new do
  link t('breadcrumbs.new_style'), new_site_admin_style_path
  parent :styles
end

crumb :styles_show do |style|
  link "#{style.name}", site_admin_style_path
  parent :styles
end

crumb :styles_edit do |style|
  link "#{t('breadcrumbs.edit')} #{style.name}", edit_site_admin_style_path
  parent :styles
end

crumb :styles_search do
  link t('breadcrumbs.search')
  parent :styles
end
