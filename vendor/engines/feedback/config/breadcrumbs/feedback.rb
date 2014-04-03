#extensions:feedback
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
  link "#{t("breadcrumbs.edit")} #{group.name}", feedback.edit_admin_group_path
  parent :groups
end

crumb :show_group do |group|
  link "#{group.name}", feedback.admin_group_path
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
  link "#{message.name}", feedback.admin_message_path
  parent :messages
end

crumb :message_search do |search|
  link "#{t("breadcrumbs.search")}/ #{search}"
  parent :messages
end
