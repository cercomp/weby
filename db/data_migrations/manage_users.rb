# Migrate permissions for manage roles

Role.find_each do |role|
  perm = eval(role.permissions || '')
  next unless perm.is_a? Hash

  if perm['users'].to_a.include?('change_roles')
    perm['users'] << 'manage_roles'
  end

  role.update(permissions: perm.to_s)
end