# Be sure to restart your server when you modify this file.
check_database = begin
    ActiveRecord::Base.connection
  rescue => err #ActiveRecord::NoDatabaseError, PG::ConnectionBad
    false
  else
    true
  end

if current_site && request.domain
  cookie_name = request.domain.parameterize(separator: '_')
  tld_length = current_site.domain.present? ? current_site.domain.split('.').length - 1 : 1
elsif
  cookie_name = check_database && Setting.table_exists? && Weby::Settings::Weby.domain.present? ? Weby::Settings::Weby.domain.parameterize(separator: '_') : 'weby3'
  tld_length  = check_database && Setting.table_exists? ? (Weby::Settings::Weby.tld_length.to_i + 1) : 2
end

Rails.application.config.session_store :cookie_store, key: "_#{cookie_name}_sess", domain: :all, tld_length: tld_length
