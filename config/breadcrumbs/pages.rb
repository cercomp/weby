# pages
crumb :pages do
  link t('breadcrumbs.pages'), site_admin_pages_path
end

crumb :pages_new do
  link t('breadcrumbs.new_page'), new_site_admin_page_path
  parent :pages
end

crumb :pages_show do |page|
  link "#{page.title}", site_admin_page_path
  parent :pages
end

crumb :pages_edit do |page|
  link "#{t('breadcrumbs.edit')} #{page.title}", edit_site_admin_page_path
  parent :pages
end

crumb :pages_search do |search|
  link "#{t('breadcrumbs.search')}/ #{search}"
  parent :pages
end

crumb :pages_recycle_bin do
  link t('recycle_bin')
  parent :pages
end
