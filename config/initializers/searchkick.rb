if ENV['ELASTICSEARCH_URL'].present?
  Searchkick.timeout = ENV['ELASTICSEARCH_TIMEOUT'].present? ? ENV['ELASTICSEARCH_TIMEOUT'].to_i : 4
  Searchkick.client_options = {
    reload_on_failure: true
  }
  if ENV['ELASTICSEARCH_PREFIX'].present?
    Searchkick.index_prefix = ENV['ELASTICSEARCH_PREFIX']
  end
  if ENV['ELASTICSEARCH_ENV'].present?
    Searchkick.env = ENV['ELASTICSEARCH_ENV']
  end
else
  Searchkick.disable_callbacks
end
