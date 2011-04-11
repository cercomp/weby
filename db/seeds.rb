require 'active_record/fixtures'
 
Dir[File.join(Rails.root, "db/seed/*.yml")].each do |filename|
  table_name = File.basename(filename, ".yml")
  Fixtures.create_fixtures('db/seed', table_name)
end

User.create do |u|
  u.login = 'admin'
  u.password = u.password_confirmation = 'admin'
  u.email = 'admin@domain.com'
  u.first_name = 'Administrador'
  u.last_name = 'do Sistema'
  u.status = true
  u.is_admin = true
end

load(Rails.root.join('db', 'seed', 'default_per_page.rb').to_s)
#Fixtures.create_fixtures("#{Rails.root}/db/seed", "*.yml")  
