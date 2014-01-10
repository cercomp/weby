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

Dir[File.join(Rails.root, "db/seed/*.rb")].each do |filename|
  load(filename)
end
