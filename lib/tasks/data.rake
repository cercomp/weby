# rake tasks for updating data

namespace :data do
  desc "run data migration"
  task :migrate => :environment do
    if ENV['file'].present?
      result = Weby::run_data_migration ENV['file']
      puts "Result: #{result}"
    else
      puts "NO ENV VAR (file)"
    end
  end
end
