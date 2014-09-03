# layout/components
crumb :layout do
  link t('breadcrumbs.components'), site_admin_components_path
end

crumb :components_new_choose do
  link t('breadcrumbs.choose_component'), new_site_admin_component_path(placeholder: params[:placeholder])
  parent :layout
end

crumb :components_new do
  link t('breadcrumbs.new_component')
  parent :components_new_choose
end

crumb :components_edit do |component|
  link "#{t('breadcrumbs.edit')} #{t("components.#{component.name}.name")}", edit_site_admin_component_path
  parent :layout
end

crumb :layout_settings do
  link t("breadcrumbs.layout_settings"), settings_site_admin_layouts_path
  parent :layout
end
