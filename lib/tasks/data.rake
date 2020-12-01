# rake tasks for updating data

namespace :data do
  desc "run data migration"
  task :migrate => :environment do
    if ENV['file'].present?
      load Rails.root.join('db', 'data_migrations', "#{ENV['file']}.rb")
    else
      puts "NO ENV VAR (file)"
    end
  end
end
