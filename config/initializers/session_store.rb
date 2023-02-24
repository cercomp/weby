# Be sure to restart your server when you modify this file.
check_database = begin
    ActiveRecord::Base.connection
  rescue => err #ActiveRecord::NoDatabaseError, PG::ConnectionBad
    false
  else
    true
  end
tld_length = check_database && Setting.table_exists? ? (Weby::Settings::Weby.tld_length.to_i + 1) : 2

Rails.application.config.session_store :cookie_store, key: '_weby3_session', domain: :all, tld_length: tld_length