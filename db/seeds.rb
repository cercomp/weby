Weby::Rights.seed_roles

user = User.new(
  login: 'admin',
  password: 'Admin1',
  password_confirmation: 'Admin1',
  email: 'admin@domain.com',
  first_name: 'Administrador',
  last_name: 'do Sistema',
  is_admin: true
)
user.skip_confirmation!
user.save!

Locale.create!(name: 'pt-BR', flag: 'Brazil.png')
Locale.create!(name: 'en',    flag: 'United States of America(USA).png')
Locale.create!(name: 'es',    flag: 'Spain.png')
Locale.create!(name: 'fr',    flag: 'France.png')
Locale.create!(name: 'zh-CN', flag: 'China.png')
Locale.create!(name: 'it',    flag: 'Italy.png')
Locale.create!(name: 'de',    flag: 'Germany.png')
