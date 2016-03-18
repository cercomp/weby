#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shibboleth, {
    request_type: :header,
#    uid_field: 'uid',
#    shib_session_id_field: "Shib-Session-ID",
#    shib_application_id_field: "Shib-Application-ID",
    info_fields: { email: 'mail', first_name: 'cn', last_name: 'sn'},
#    provider_ignores_state: true,
#    extra_fields: [ :"unscoped-affiliation", :entitlement ],
    debug: false
  }
#  on_failure { |env| 
#    ShibbolethsController.action(:shib).call(env) 
#  }
#  provider :cas, 
#    url: 'https://ufgnet.ufg.br/cas',
#    disable_ssl_verification: true,
#    service_validate_url: '/serviceValidade'
end
