require 'active_record/fixtures'
 
Dir[File.join(Rails.root, "db/seed/*.yml")].each do |filename|
  table_name = File.basename(filename, ".yml")
  Fixtures.create_fixtures('db/seed', table_name)
end
 
#Fixtures.create_fixtures("#{Rails.root}/db/seed", "*.yml")  
