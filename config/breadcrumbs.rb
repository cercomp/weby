#Breadcrumbs apenas na área administrativa dos portais

crumb :root do
  link t("breadcrumbs.home"), main_app.site_admin_path
end


#repositories
crumb :repositories do
  link t("breadcrumbs.repositories"), site_admin_repositories_path
end

crumb :repositories_new do
  link t("breadcrumbs.new_repository"), new_site_admin_repository_path
  parent :repositories
end

crumb :repositories_edit do |repository|
  link "#{t("breadcrumbs.edit")}-#{repository.description}", edit_site_admin_repository_path
  parent :repositories
end

crumb :repositories_show do |repository|
  link "#{t("breadcrumbs.show")}-#{repository.description}", site_admin_repository_path
  parent :repositories
end

crumb :repositories_search do
  link t("breadcrumbs.search")
  parent :repositories
end

#pages
crumb :pages do
  link t("breadcrumbs.pages"), site_admin_pages_path
end

crumb :pages_new do
  link t("breadcrumbs.new_page"), new_site_admin_page_path
  parent :pages
end

crumb :pages_fronts do
  link t("breadcrumbs.fronts"), fronts_site_admin_pages_path
  parent :pages
end

crumb :pages_show do |page|
  link "#{t("breadcrumbs.show")}-#{page.title}", site_admin_page_path
  parent :pages
end

crumb :pages_edit do |page|
  link "#{t("breadcrumbs.edit")}-#{page.title}", edit_site_admin_page_path
  parent :pages
end

crumb :pages_search do
  link t("breadcrumbs.search")
  parent :pages
end

#menus/item_menu
crumb :menus do
  link t("breadcumbs.menus"), site_admin_menus_path
end

crumb :menus_new do
  link t("breadcrumbs.new_menu"), new_site_admin_menu_path
  parent :menus
end

crumb :menus_edit do |menu|
  link "#{t("breadcrumbs.edit")}-#{menu.name}", edit_site_admin_path
  parent :menus
end

crumb :menus_items_new do |menu|
  link "#{t("breadcrumbs.new_menu_item")}(Menu-#{menu.name})"
  parent :menus
end

crumb :edit_menu_item do |menu|
  link "#{t("breadcrumbs.edit_menu_item")}(Menu-#{menu.name})"
  parent :menus
end

#banners
crumb :banners do
  link t("breadcrumbs.banners"), site_admin_banners_path
end

crumb :banners_new do
  link t("breadcrumbs.new_banner"), new_site_admin_banner_path
  parent :banners
end

crumb :banners_edit do |banner|
  link "#{t("breadcrumbs.edit")}-#{banner.title}", edit_site_admin_banner_path
  parent :banners
end

crumb :banners_show do |banner|
  link "#{t("breadcrumbs.show")}-#{banner.title}", site_admin_banner_path
  parent :banners
end

crumb :banners_search do
  link t("breadcrumbs.search")
  parent :banners
end

#roles/users
crumb :users do
  link t("breadcrumbs.users"), manage_roles_admin_users_path
end

crumb :roles do
  link t("breadcrumbs.roles"), admin_roles_path
  parent :users
end

crumb :roles_new do
  link t("breadcrumbs.new_role"), new_site_admin_role_path
  parent :roles
end

crumb :roles_edit do |role|
  link "#{t("breadcrumbs.edit")}-#{role.name}", edit_site_admin_role_path
  parent :roles
end

#styles
crumb :styles do
  link t("breadcrumbs.styles"), site_admin_styles_path
end

crumb :styles_new do
  link t("breadcrumbs.new_style"), new_site_admin_style_path
  parent :styles
end

crumb :styles_show do |style|
  link "#{t("breadcrumbs.show")}-#{style.name}", site_admin_style_path
  parent :styles
end

crumb :styles_edit do |style|
  link "#{t("breadcrumbs.edit")}-#{style.name}", edit_site_admin_style_path
  parent :styles
end

crumb :styles_search do
  link t("breadcrumbs.search")
  parent :styles
end

#statistics
crumb :statistics do
  link t("breadcrumbs.statistics"), admin_stats_path
end

#settings
crumb :settings do
  link t("breadcrumbs.settings"), edit_site_admin_path
end

#activity_records
crumb :activity_records do
  link t("breadcrumbs.activity_records"), site_admin_activity_records_path
end

crumb :activity_records_details do
  link t("breadcrumbs.activity_records_details"), site_admin_activity_record_path
  parent :activity_records
end

#layout/components
crumb :layout do
  link t("breadcrumbs.components"), site_admin_components_path
end

crumb :components_new_choose do
  link t("breadcrumbs.choose_component"), new_site_admin_component_path(placeholder: params[:placeholder])
  parent :layout
end

crumb :components_new do
  link t("breadcrumbs.new_component")
  parent :components_new_choose
end

crumb :components_edit do |component|
  link "#{t("breadcrumbs.edit")}-#{t("components.#{component.name}.name")}", edit_site_admin_component_path
  parent :layout
end

#extensions;feedback
crumb :extensions do
  link t("breadcrumbs.extensions"), main_app.site_admin_extensions_path
end

crumb :new_extension do
  link t("breadcrumbs.new_extension"), new_site_admin_extension_path
  parent :extensions
end

crumb :feedback do 
  link t("breadcrumbs.feedback"), feedback.admin_path
  parent :extensions
end

crumb :new_group do 
  link t("breadcrumbs.new_group"), feedback.new_admin_group_path
  parent :feedback
end

crumb :edit_group do |group|
  link "#{t("breadcrumbs.edit")}-#{group.name}", feedback.edit_admin_group_path
  parent :groups
end

crumb :show_group do |group|
  link "#{t("breadcrumbs.show")}-#{group.name}", feedback.admin_group_path
  parent :groups
end

crumb :groups do
  link t("breadcrumbs.groups"), feedback.admin_groups_path
  parent :feedback
end

crumb :messages do 
  link t("breadcrumbs.messages"), feedback.admin_messages_path
  parent :feedback
end

crumb :show_message do |message|
  link "#{t("breadcrumbs.show")}-#{message.name}", feedback.admin_message_path
  parent :messages
end
