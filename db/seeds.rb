require 'active_record/fixtures'
 
Dir[File.join(Rails.root, "db/seed/*.yml")].each do |filename|
  table_name = File.basename(filename, ".yml")
  Fixtures.create_fixtures('db/seed', table_name)
end

User.create do |u|
  u.login = 'admin'
  u.password = u.password_confirmation = 'admin'
  u.email = 'admin@domain.com'
  u.status = true
  u.is_admin = true
end

Role.create :name => 'manager'
 
#Fixtures.create_fixtures("#{Rails.root}/db/seed", "*.yml")  
