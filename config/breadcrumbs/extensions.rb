# extensions
crumb :extensions do
  link t('breadcrumbs.extensions'), main_app.site_admin_extensions_path
end

crumb :new_extension do
  link t('breadcrumbs.new_extension'), main_app.new_site_admin_extension_path
  parent :extensions
end

crumb :edit_extension do |extension|
  link "#{t('breadcrumbs.edit_extension')} #{t("extensions.#{extension.name}.name")}",
        main_app.edit_site_admin_extension_path(extension)
  parent :extensions
end
