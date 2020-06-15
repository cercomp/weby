# styles
crumb :styles do |skin|
  link t('breadcrumbs.styles'), skin.site_id == current_site.id ? site_admin_skin_path(skin, anchor: 'tab-styles') : ''
  parent :skins_show, skin
end

crumb :styles_new do |skin|
  link t('breadcrumbs.new_style'), new_site_admin_skin_style_path(skin)
  parent :styles, skin
end

crumb :styles_show do |skin, style|
  link "#{style.name}", skin.site_id == current_site.id ? site_admin_skin_style_path(skin, style) : ''
  parent :styles, skin
end

crumb :styles_edit do |skin, style|
  link "#{t('breadcrumbs.edit')} #{style.name}", edit_site_admin_skin_style_path(skin, style)
  parent :styles, skin
end

crumb :styles_search do |skin|
  link t('breadcrumbs.search')
  parent :styles, skin
end
