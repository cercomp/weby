require 'active_record/fixtures'
 
Dir[File.join(Rails.root, "db/seed/*.yml")].each do |filename|
  table_name = File.basename(filename, ".yml")
  ActiveRecord::Fixtures.create_fixtures('db/seed', table_name)
end

User.create do |u|
  u.login = 'admin'
  u.password = u.password_confirmation = 'Admin1'
  u.email = 'admin@domain.com'
  u.first_name = 'Administrador'
  u.last_name = 'do Sistema'
  u.status = true
  u.is_admin = true
end

load(Rails.root.join('db', 'seed', 'default_per_page.rb').to_s)
#load(Rails.root.join('db', 'seed', 'default_settings.rb').to_s)
#Fixtures.create_fixtures("#{Rails.root}/db/seed", "*.yml")  

# Permissões Globais
Role.create :name => 'Gerente',
  :right_ids => ["26", "23", "24", "25", "27", "22", "47", "45", "46", "43",
                 "48", "49", "44", "32", "30", "31", "28", "29", "21", "18",
                 "19", "16", "20", "17", "14", "11", "12", "9", "13", "15",
                 "10", "42", "40", "41", "38", "39", "6", "5", "61", "62",
                 "63", "64", "65"]

Role.create :name => 'Editor-Chefe',
  :right_ids => ["26", "23", "24", "25", "27", "22", "21", "18", "19", "16",
                 "20", "17", "14", "11", "12", "9", "13", "15", "10", "42",
                 "40", "38", "39", "61", "62", "63", "64", "65"]

Role.create :name => 'Redator',
  :right_ids => ["14", "11", "9", "10"]
