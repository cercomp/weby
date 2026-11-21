# Be sure to restart your server when you modify this file.
settings_available, domain, tld_length_setting = begin
  if ActiveRecord::Base.connection&.data_source_exists?('settings')
    [
      true,
      ActiveRecord::Base.connection.select_value("SELECT value FROM settings WHERE name = 'domain' LIMIT 1"),
      ActiveRecord::Base.connection.select_value("SELECT value FROM settings WHERE name = 'tld_length' LIMIT 1")
    ]
  else
    [false, nil, nil]
  end
rescue StandardError
  [false, nil, nil]
end

cookie_name = domain.present? ? domain.parameterize(separator: '_') : 'weby3'
tld_length = if tld_length_setting.present?
  [tld_length_setting.to_i + 1, 2].max
elsif domain.present?
  [domain.split('.').length, 2].max
else
  2
end

Rails.application.config.session_store :cookie_store, key: "_#{cookie_name}_sess", domain: :all, tld_length: tld_length
