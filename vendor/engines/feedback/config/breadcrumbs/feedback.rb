# extensions:feedback
crumb :feedback do
  link t('breadcrumbs.feedback'), admin_feedback_path
  parent :extensions
end

crumb :new_group do
  link t('breadcrumbs.new_group'), new_admin_group_path
  parent :feedback
end

crumb :edit_group do |group|
  link "#{t('breadcrumbs.edit')} #{group.name}", edit_admin_group_path(group)
  parent :groups
end

crumb :show_group do |group|
  link "#{group.name}", admin_group_path(group)
  parent :groups
end

crumb :groups do
  link t('breadcrumbs.groups'), admin_groups_path
  parent :feedback
end

crumb :messages do
  link t('breadcrumbs.messages'), admin_messages_path
  parent :feedback
end

crumb :show_message do |message|
  link "#{message.name}", admin_message_path(message)
  parent :messages
end

crumb :message_search do |search|
  link "#{t('breadcrumbs.search')}/ #{search}"
  parent :messages
end
