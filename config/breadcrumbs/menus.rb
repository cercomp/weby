# menus/item_menu
crumb :menus do
  link t('breadcrumbs.menus'), site_admin_menus_path
end

crumb :menus_new do
  link t('breadcrumbs.new_menu'), new_site_admin_menu_path
  parent :menus
end

crumb :menus_edit do |menu|
  link "#{t('breadcrumbs.edit')} #{menu.name}", edit_site_admin_path
  parent :menus
end

crumb :menus_items_new do |menu|
  link "#{t('breadcrumbs.new_menu_item')} (#{menu.name})"
  parent :menus
end

crumb :edit_menu_item do |menu|
  link "#{t('breadcrumbs.edit_menu_item')} (#{menu.name})"
  parent :menus
end
