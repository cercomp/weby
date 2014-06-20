# Breadcrumbs
crumb :root do
  link t('breadcrumbs.home'), main_app.site_admin_path
end

# settings
crumb :settings do
  link t('breadcrumbs.settings'), edit_site_admin_path
end
