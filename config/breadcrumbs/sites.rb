# admin sites
crumb :admin_sites do
  link t('breadcrumbs.sites'), admin_sites_path
end

crumb :admin_site_edit do |site|
  link "#{t('breadcrumbs.edit')} #{site.title}", edit_admin_site_path
  parent :admin_sites
end
