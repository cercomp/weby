# Puma configuration for Weby

# Threads per worker
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
threads threads_count, threads_count

# Bind port
port ENV.fetch('PORT', 3000)

# Environment
environment ENV.fetch('RAILS_ENV', 'development')

# Clustered mode (workers) for production
workers_count = ENV.fetch('WEB_CONCURRENCY', 2).to_i
if ENV['RAILS_ENV'] == 'production' && workers_count > 1
  workers workers_count
  preload_app!
end

on_worker_boot do
  # Worker specific setup for Rails
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

plugin :tmp_restart
