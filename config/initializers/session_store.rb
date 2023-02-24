# Be sure to restart your server when you modify this file.
check_database = begin
    ActiveRecord::Base.connection
  rescue => err #ActiveRecord::NoDatabaseError, PG::ConnectionBad
    false
  else
    true
  end
tld_length  = check_database && Setting.table_exists? ? (Weby::Settings::Weby.tld_length.to_i + 1) : 2
cookie_name = check_database && Setting.table_exists? && Weby::Settings::Weby.domain.present? ? Weby::Settings::Weby.domain.parameterize(separator: '_') : 'weby3'

Rails.application.config.session_store :cookie_store, key: "_#{cookie_name}_sess", domain: :all, tld_length: tld_length