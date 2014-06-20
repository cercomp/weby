# repositories
crumb :repositories do
  link t('breadcrumbs.repositories'), site_admin_repositories_path
end

crumb :repositories_new do
  link t('breadcrumbs.new_repository'), new_site_admin_repository_path
  parent :repositories
end

crumb :repositories_edit do |repository|
  link "#{t('breadcrumbs.edit')} #{repository.description}", edit_site_admin_repository_path
  parent :repositories
end

crumb :repositories_show do |repository|
  link "#{repository.description}", site_admin_repository_path
  parent :repositories
end

crumb :repositories_search do |search|
  link "#{t('breadcrumbs.search')}/ #{search}"
  parent :repositories
end

crumb :repositories_recycle_bin do
  link t('recycle_bin')
  parent :repositories
end
