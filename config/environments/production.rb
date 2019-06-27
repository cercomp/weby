Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  config.active_record.raise_in_transactional_callbacks = true

  # Disable Rails's static files server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  if ENV['STORAGE_BUCKET'].present?
    region = 'us-east-1'

    config.paperclip_defaults = {
      storage: :s3,
      s3_protocol: :https,
      s3_permissions: 'private',
      s3_region: region,
      s3_headers: {
        'Cache-Control' => 'public, s-maxage=31536000, maxage=15552000',
        'Expires' => 1.year.from_now.to_formatted_s(:rfc822).to_s
      },
      s3_credentials: {
        bucket: ENV['STORAGE_BUCKET'],
        access_key_id: ENV['STORAGE_ACCESS_KEY'],
        secret_access_key: ENV['STORAGE_ACCESS_SECRET'],
      },
      s3_host_name: ENV['STORAGE_HOST'],
      s3_options: {
        endpoint: "https://#{ENV['STORAGE_HOST']}", # for aws-sdk
        force_path_style: true # for aws-sdk (required for minio)
      },
      url: ':s3_path_url'
    }

    AssetSync.configure do |config|
      config.fog_provider = 'AWS'
      config.aws_access_key_id = ENV['STORAGE_ACCESS_KEY']
      config.aws_secret_access_key = ENV['STORAGE_ACCESS_SECRET']
      config.fog_directory = ENV['STORAGE_BUCKET']
      config.fog_region = region
      config.fog_host = ENV['STORAGE_HOST']
      config.fog_path_style = true
    end
  end

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  asset_host = ENV['STORAGE_HOST'].present? ? "//#{ENV['STORAGE_HOST']}/#{ENV['STORAGE_BUCKET']}" : proc {|*args| Weby::Assets.asset_host_for(args[0], args[1] || nil) }
  config.action_controller.asset_host = asset_host
  config.action_mailer.asset_host = asset_host

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
