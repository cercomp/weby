# roles/users
crumb :users do
  link t('breadcrumbs.users'), manage_roles_admin_users_path
end

crumb :roles do
  link t('breadcrumbs.roles'), admin_roles_path
  parent :users
end

crumb :roles_new do
  link t('breadcrumbs.new_role'), new_site_admin_role_path
  parent :roles
end

crumb :roles_edit do |role|
  link "#{t('breadcrumbs.edit')} #{role.name}", edit_site_admin_role_path
  parent :roles
end
