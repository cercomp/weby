# layout/components
crumb :components do |skin|
  link t('breadcrumbs.components'), site_admin_skin_path(skin, anchor: 'tab-layout')
  parent :skins_show, skin
end

crumb :components_new_choose do |skin|
  link t('breadcrumbs.choose_component'), new_site_admin_skin_component_path(skin, placeholder: params[:placeholder])
  parent :components, skin
end

crumb :components_new do |skin|
  link t('breadcrumbs.new_component')
  parent :components_new_choose, skin
end

crumb :components_edit do |skin, component|
  link "#{t('breadcrumbs.edit')} #{t("components.#{component.name}.name")}", edit_site_admin_skin_component_path
  parent :components, skin
end

crumb :layout_settings do
  link t("breadcrumbs.layout_settings"), settings_site_admin_layouts_path
  parent :skins
end
