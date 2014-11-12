print('Updating Roles...')
Role.find_each do |role|
  if role.permissions && role.permissions.match(/^{/)
    perm = eval(role.permissions)

    actions = perm['pages'].dup

    perm['news'] = actions.dup
    actions.delete('sort')
    perm['events'] = actions
    perm['pages'] = actions
    role.update_attribute :permissions, perm.to_s
  end
end
print("OK\n")
print("Updating Components...")
Component.where(name: 'front_news').find_each do |component|
  sett = eval(component.settings)
  if sett['type_filter'] == 'events'
    component.name = 'event_list'
    sett['template'] = 'front'
    sett.delete('order_by')
  end
  if sett['order_by'] == 'event_begin'
    sett['order_by'] = 'created_at'
  end
  sett.delete('type_filter')
  component.settings = sett.to_s
  component.save
end
print("OK\n")