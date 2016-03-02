if Rails.env.production? && Setting.table_exists?
  if Weby::Settings::Email.smtp_address.present?
    # Enable deliveries
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.delivery_method = Weby::Settings::Email.delivery_method.to_sym
    ActionMailer::Base.smtp_settings = {
      address: Weby::Settings::Email.smtp_address,
      port: Weby::Settings::Email.smtp_port.to_i,
      authentication: Weby::Settings::Email.smtp_authentication.to_sym,
      enable_starttls_auto: Weby::Settings::Email.smtp_enable_starttls_auto.to_s.eql?('true'),
      user_name: Weby::Settings::Email.smtp_user_name,
      password: Weby::Settings::Email.smtp_password
    }
  end
end
