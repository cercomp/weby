# Migrate permissions for themes

Role.find_each do |role|
  perm = eval(role.permissions || '')
  next unless perm.is_a? Hash
  if perm['styles'].to_a.include?('index') || perm['components'].to_a.include?('index')
    (perm['skins'] ||= []) << 'index'
  end
  if perm['styles'].to_a.include?('new') || perm['components'].to_a.include?('new')
    (perm['skins'] ||= []) << 'create'
    perm['skins'] << 'preview'
  end
  if perm['styles'].to_a.include?('destroy') || perm['components'].to_a.include?('destroy')
    (perm['skins'] ||= []) << 'destroy'
  end
  if perm['skins'].to_a.any?
    perm['skins'].uniq!
  end
  role.update(permissions: perm.to_s)
end