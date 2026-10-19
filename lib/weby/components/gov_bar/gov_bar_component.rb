class GovBarComponent < Component
  component_settings :script_url

  DEFAULT_SCRIPT_URL = '//barra.brasil.gov.br/barra.js'.freeze

  def script_url
    settings_map[:script_url].presence || DEFAULT_SCRIPT_URL
  end
end
