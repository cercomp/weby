Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'lvh.me:3000' }
  #config.action_mailer.asset_host = 'http://lvh.me:3000'
  config.action_mailer.delivery_method = :letter_opener
  asset_host = proc {|*args| Weby::Assets.asset_host_for(args[0], args[1] || nil) }
  config.action_controller.asset_host = asset_host
  config.action_mailer.asset_host = asset_host

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  # config.assets.raise_runtime_errors = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  #config.logger = ActiveSupport::Logger.new(config.paths['log'].first, 1, 500.megabytes)

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  AssetSync.config.enabled = false

  config.after_initialize do
    Bullet.enable = true
    #Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    #Bullet.growl = true
    #Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #                :password => 'bullets_password_for_jabber',
    #                :receiver => 'your_account@jabber.org',
    #                :show_online_status => true }
    #Bullet.rails_logger = true
    #Bullet.honeybadger = true
    #Bullet.bugsnag = true
    #Bullet.airbrake = true
    #Bullet.rollbar = true
    Bullet.add_footer = false
    #Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    #Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
    #Bullet.slack = { webhook_url: 'http://some.slack.url', foo: 'bar' }
  end

end
