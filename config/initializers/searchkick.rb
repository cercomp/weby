if ENV['ELASTICSEARCH_URL'].present?
  Searchkick.timeout = ENV['ELASTICSEARCH_TIMEOUT'].to_i if ENV['ELASTICSEARCH_TIMEOUT'].present?
  #Searchkick.client = Elasticsearch::Client.new(hosts: [hosts], retry_on_failure: true, transport_options: {request: {timeout: 250}})
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
