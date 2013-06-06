require 'active_record/fixtures'

# Fix foreigner gem problem with fixtures on postgres
# read more: https://github.com/matthuhiggins/foreigner/issues/61
class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def supports_disable_referential_integrity?
    false
  end
end
 
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

