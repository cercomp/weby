AuthSource.ldap.includes(:user).find_each do |source|
  source.user.clear_password!
end
